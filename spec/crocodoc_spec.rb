require 'spec_helper'

describe Crocodoc do
  before do
    Crocodoc.configure do |config|
      config.token = 'testblah1234'
    end

    @crocodoc = Crocodoc::API.new
    @crocodoc.http = Crocodoc::FakeServer.new({:token => Crocodoc.config.token})
  end

  describe "#upload" do
    it "should upload a url successfully" do
      response = @crocodoc.upload("http://www.example.com/text.doc")
      response['uuid'].should_not be_nil
    end

    it "should upload a document successfully" do
      pending "TODO: implement file uploads"

      @file = File.open(File.dirname(__FILE__) + '../fixtures/doc.doc')
      response = @crocodoc.upload(@file)
      response['uuid'].should_not be_nil
    end
  end

  describe "#status" do
    it "should check the status of a single document" do
      uuid = @crocodoc.upload("http://www.example.com/text.doc")['uuid']
      response = @crocodoc.status(uuid)
      response['uuid'].should == uuid
      response['status'].should_not be_nil
      response['viewable'].should_not be_nil
      response['error'].should be_nil
    end

    it "should check the status of multiple documents" do
      uuids = []
      3.times do |i|
        uuids << @crocodoc.upload("http://www.example.com/text#{i}.doc")['uuid']
      end
      response = @crocodoc.status(uuids)
      response.map { |j| j['uuid'] }.sort.should == uuids.sort
      response.all? { |j| j['status'] }.should be_true
      response.all? { |j| j['viewable'] }.should be_true
      response.any? { |j| j['error'] }.should be_false
    end

    it "should return an error for invalid doc ids" do
      response = @crocodoc.status("666")
      response['error'].should match(/invalid/)
    end
  end

  describe "#delete" do
    it "should delete a document" do
      uuid = @crocodoc.upload("http://www.example.com/text.doc")['uuid']
      response = @crocodoc.delete(uuid)
      response.should be_true
    end

    it "should return an error when deleting an already deleted document" do
      uuid = @crocodoc.upload("http://www.example.com/text.doc")['uuid']
      @crocodoc.delete(uuid)
      lambda { @crocodoc.delete(uuid) }.should raise_error
    end
  end

  describe "#download" do
    it "should provide the download url for a doc" do
      uuid = "8e5b0721-26c4-11df-b354-002170de47d3"

      url = @crocodoc.download(uuid)

      url.should eq('https://crocodoc.com/api/v2/download/document?token=testblah1234&uuid=8e5b0721-26c4-11df-b354-002170de47d3')
    end
  end

  describe "#thumbnail" do
    it "should provide url without optional size" do
      uuid = "8e5b0721-26c4-11df-b354-002170de47d3"
      url = @crocodoc.thumbnail(uuid)
      url.should eq('https://crocodoc.com/api/v2/download/thumbnail?token=testblah1234&uuid=8e5b0721-26c4-11df-b354-002170de47d3')
    end

    it "should provide url with optional size provided" do
      uuid = "8e5b0721-26c4-11df-b354-002170de47d3"
      url = @crocodoc.thumbnail(uuid, {:size => '300x250'})
      url.should eq('https://crocodoc.com/api/v2/download/thumbnail?size=300x250&token=testblah1234&uuid=8e5b0721-26c4-11df-b354-002170de47d3')
    end
  end

  describe "#text" do
    it "should provide document's text" do
      uuid = "8e5b0721-26c4-11df-b354-002170de47d3"
      text = @crocodoc.text(uuid)

      text.should eq("The quick brown fox jumps over the lazy dog.")
    end
  end

  describe "#session" do
    it "should create a session for a doc" do
      uuid = @crocodoc.upload("http://www.example.com/text.doc")['uuid']
      response = @crocodoc.session(uuid)
      response['session'].should_not be_nil
    end

    it "should create a session with custom arguments" do
      uuid = @crocodoc.upload("http://www.example.com/text.doc")['uuid']
      response = @crocodoc.session(uuid, {
        :editable => true,
        :user => '1,Luke',
        :filter => 'all',
        :admin => true,
        :downloadable => true,
        :copyprotected => true
      })
      response['session'].should_not be_nil
      # no real way to test that the args went through :(
    end

    it "should raise an error for an invalid doc" do
      lambda { @crocodoc.session('999') }.should raise_error
    end

    it "should raise an error for an invalid user" do
      uuid = @crocodoc.upload("http://www.example.com/text.doc")['uuid']
      lambda {
        response = @crocodoc.session(uuid, {
          :editable => true,
          :user => '1Luke',
        })
      }.should raise_error
    end
  end
end
