module Crocodoc
  class FakeServer
    attr_accessor :ids, :docs, :token
    def initialize(opts)
      @ids = 0
      @docs = {}
      @token = opts[:token]
    end

    def next_uuid
      (@ids += 1).to_s
    end

    def request(req, body=nil)
      # normalize path and params
      case req.method
      when "GET"
        path, params = req.path.split("?")
      when "POST"
        path = req.path
        params = req.body
      end

      # verify correct api version
      unless path.start_with? "/api/v2/"
        return Crocodoc::FakeResponse.new("404", "")
      end
      path.gsub!("/api/v2/", "")

      # parse params
      params = params.split("&")
      params = params.inject({}) do |hsh, p|
        k,v = p.split("=")
        hsh[k.to_s] = CGI::unescape(v)
        hsh
      end

      # verify token
      unless params['token'] == @token
        return Crocodoc::FakeResponse.new("401", {
          :error => "invalid API token"
        }.to_json)
      end
      
      # dispatch
      self.send(path.gsub("/", "_"), req.method, params)
    rescue => exception
      return Crocodoc::FakeResponse.new("500", exception.message)
    end

    def document_upload(verb, params)
      # Failure cases
      unless verb == "POST"
        return Crocodoc::FakeResponse.new("405", "")
      end
      unless params['url'] || params['file']
        return Crocodoc::FakeResponse.new("400", {
          :error => "no url or file specified"
        }.to_json)
      end

      # Store doc and succeed
      uuid = next_uuid
      @docs[uuid] = params['url']
      Crocodoc::FakeResponse.new("200", {
        :uuid => uuid
      }.to_json)
    end

    def document_status(verb, params)
      # Failure cases
      unless verb == "GET"
        return Crocodoc::FakeResponse.new("405", "")
      end
      unless params['uuids']
        return Crocodoc::FakeResponse.new("400", {
          :error => "missing parameter uuids"
        }.to_json)
      end

      # Build response and succeed
      uuids = params['uuids'].split(",")
      res = uuids.map do |uuid|
        if @docs[uuid]
          {
            :status => "DONE",
            :uuid => uuid,
            :viewable => true
          }
        else
          {
            :uuid => uuid,
            :error => "invalid uuid"
          }
        end
      end
      Crocodoc::FakeResponse.new("200", res.to_json)
    end

    def document_delete(verb, params)
      # Failure cases
      unless verb == "POST"
        return Crocodoc::FakeResponse.new("405", "")
      end
      unless params['uuid'] && @docs[params['uuid']]
        return Crocodoc::FakeResponse.new("400", {
          :error => "invalid document uuid"
        }.to_json)
      end

      # Remove doc and succeed
      @docs.delete(params['uuid'])
      Crocodoc::FakeResponse.new("200", "true")
    end

    def download_text(verb, params)
      Crocodoc::FakeResponse.new("200", "The quick brown fox jumps over the lazy dog.")
    end

    def session_create(verb, params)
      # Failure cases
      unless verb == "POST"
        return Crocodoc::FakeResponse.new("405", "")
      end
      unless params['uuid'] && @docs[params['uuid']]
        return Crocodoc::FakeResponse.new("400", {
          :error => "invalid uuid"
        }.to_json)
      end
      if params['editable'] == 'true' && params['user']
        user = params['user'].split(",")
        if user.length != 2 || user.first != user.first.to_i.to_s || user.first.to_i >= (2**31)
          return Crocodoc::FakeResponse.new("400", {
            :error => "invalid user ID"
          }.to_json)
        end
      end

      # Generate session uuid and succeed
      uuid = next_uuid
      Crocodoc::FakeResponse.new("200", {
        :session => uuid
      }.to_json)
    end

    def method_missing(m, *args, &block) 
      Crocodoc::FakeResponse.new("404", "")
    end
  end

  class FakeResponse
    attr_accessor :code, :body
    def initialize(code, body)
      @code = code
      @body = body
    end
  end
end
