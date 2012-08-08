require 'spec_helper'

describe Crocodoc do
  before do
    opts = { :token => "testblah1234" }
    @crocodoc = Crocodoc::API.new(opts)
    @crocodoc.http = Crocodoc::FakeServer.new(opts)
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
