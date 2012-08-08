module Crocodoc
  # Public: A small ruby client that wraps the Crocodoc api.
  #
  # Examples
  #
  #   Crocodoc::API.new(:token => <token>).status(<uuid>)
  #   # => { "uuid": <uuid>, "status": "DONE", "viewable": true }
  class API
    attr_accessor :token, :http, :url

    # Public: The base part of the url that is the same for all api requests.
    BASE_URL = "https://crocodoc.com/api/v2"

    # Public: Initialize a Crocodoc api object
    #
    # opts - A hash of options with which to initialize the object
    #        :token - The api token to use to authenticate requests. Required.
    #        
    # Examples
    #   crocodoc = Crocodoc::API.new(:token => <token>)
    #   # => <Crocodoc::API:<id>>
    def initialize(opts)
      self.token = opts[:token]

      # setup the http object for ssl
      @url = URI.parse(BASE_URL)
      @http = Net::HTTP.new(@url.host, @url.port)
      @http.use_ssl = true
    end

    # -- Documents --

    # Public: Upload a url or file. Uploading is asynchronous, so this method
    # returns immediately.
    #
    #   POST https://crocodoc.com/api/v2/document/upload
    #
    # obj - a url string or file to upload
    #
    # Examples
    #
    #   upload("http://www.example.com/test.doc")
    #   # => { "uuid": "8e5b0721-26c4-11df-b354-002170de47d3" }
    #
    # Returns a hash containing the uuid of the document and possibly an error
    #   explaining why the upload failed.
    def upload(obj)
      params = if obj.is_a?(File)
        { :file => obj }
        raise Crocodoc::Error, "TODO: support raw files"
      else
        { :url => obj.to_s }
      end

      raw_body = api_call(:post, "document/upload", params)
      JSON.parse(raw_body)
    end

    # Public: Get the status of a set of documents.
    #
    #   GET https://crocodoc.com/api/v2/document/status
    #
    # uuids - a single uuid or an array of uuids
    #
    # Examples
    #
    #   status(["6faad04f-5409-4173-87aa-97c1fd1f35ad",
    #           "7cf917de-2246-4ac3-adab-791a49454180"])
    #   # =>
    #   # [
    #   #   {
    #   #     "uuid": "7cf917de-2246-4ac3-adab-791a49454180"
    #   #     "status": "DONE",
    #   #     "viewable": true,
    #   #   },
    #   #   {
    #   #     "uuid": "6faad04f-5409-4173-87aa-97c1fd1f35ad"
    #   #     "status": "ERROR",
    #   #     "viewable": false,
    #   #     "error": "password protected"
    #   #   }
    #   # ]
    #
    # Returns a single hash or an array of hashes containing the status
    #   information for the uuid.
    def status(uuids)
      raw_hash_body = api_call(:get, "document/status", { :uuids => Array(uuids).join(",") })
      hash_body = JSON.parse(raw_hash_body)
      uuids.is_a?(String) ? hash_body.first : hash_body
    end

    # Public: Delete a document.
    #
    #   POST https://crocodoc.com/api/v2/document/delete
    #
    # uuid - a single uuid to delete
    #
    # Examples
    #
    #   delete("7cf917de-2246-4ac3-adab-791a49454180")
    #   # => true
    #
    # Returns true if the delete was successful
    def delete(uuid)
      raw_body = api_call(:post, "document/delete", { :uuid => uuid })
      raw_body == "true"
    end

    # -- Sessions --

    # Public: Create a session, which is a unique id with which you can view
    # the document. Sessions expire 60 minutes after they are generated.
    #
    #   POST https://crocodoc.com/api/v2/session/create
    #
    # uuid - The uuid of the document for the session
    # opts - Options for the session (default: {}):
    #        :editable      - Allows users to create annotations and comments
    #                         while viewing the document (default: false)
    #        :user          - A user ID and name joined with a comma (e.g.:
    #                         1337,Peter). The ID should be a non-negative
    #                         signed 32-bit integer (0 <= ID <= 2,147,483,647)
    #                         and unique for each user across your
    #                         application's userbase. The user name will be
    #                         shown in the viewer to attribute annotations and
    #                         comments to their author. Required if editable is
    #                         true
    #        :filter        - Limits which users' annotations and comments are
    #                         shown. Possible values are: all, none, or
    #                         a comma-separated list of user IDs as specified
    #                         in the user field (default: all)
    #        :admin         - Allows the user to modify or delete any
    #                         annotations and comments; including those
    #                         belonging to other users. By default, users may
    #                         only modify/delete their own annotations or reply
    #                         to other users' comments. (default: false)
    #        :downloadable  - Allows the user to download the original
    #                         document (default: false)
    #        :copyprotected - Prevents document text selection. Although
    #                         copying text will still be technically possible
    #                         since it's just HTML, enabling this option makes
    #                         doing so difficult (default: false)
    #        :demo          - Prevents document changes such as creating,
    #                         editing, or deleting annotations from being
    #                         persisted (default: false)
    #
    # Examples
    #
    #   session("6faad04f-5409-4173-87aa-97c1fd1f35ad")
    #   # => { "session": "CFAmd3Qjm_2ehBI7HyndnXKsDrQXJ7jHCuzcRv" }
    #
    # Returns a hash containing the session uuid
    def session(uuid, opts={})
      raw_body = api_call(:post, "session/create", opts.merge({ :uuid => uuid }))
      JSON.parse(raw_body)
    end

    # Public: Get the url for the viewer for a session.
    #
    #   https://crocodoc.com/view/<session>
    #
    # session - The uuid of the session (see #session)
    #
    # Examples
    #   view("CFAmd3Qjm_2ehBI7HyndnXKsDrQXJ7jHCuzcRv_V4FAgbSmaBkF")
    #   # => https://crocodoc.com/view/"CFAmd3Qjm_2ehBI7HyndnXKsDrQXJ7jHCuzcRv"
    #
    # Returns a url string for viewing the session
    def view(session_id)
      "https://crocodoc.com/view/#{session_id}"
    end

    # -- Downloads (TODO) --

    # GET https://crocodoc.com/api/v2/download/document
    def download(doc)
      raise Crocodoc::Error, "Not implemented"
    end

    # GET https://crocodoc.com/api/v2/download/thumbnail
    def thumbnail(doc)
      raise Crocodoc::Error, "Not implemented"
    end
    
    # GET https://crocodoc.com/api/v2/download/text
    def text(doc)
      raise Crocodoc::Error, "Not implemented"
    end

    # -- API Glue --

    # Internal: Setup the api call, format the parameters, send the request,
    # parse the response and return it.
    #
    # method   - The http verb to use, currently :get or :post
    # endpoint - The api endpoint to hit. this is the part after
    #            crocodoc.com/api/v2. please do not include a beginning slash.
    # params   - Parameters to send with the api call, either as a query string
    #            (get) or form params (post). Don't worry about including the
    #            api token, it will automatically be included with all
    #            requests (default: {}).
    #
    # Examples
    #
    #   api_call(:post,
    #            "document/upload",
    #            { :url => "http://www.example.com/test.doc" })
    #   # => { "uuid": "8e5b0721-26c4-11df-b354-002170de47d3" }
    #
    # Returns the json parsed response body of the call
    def api_call(method, endpoint, params={})
      # add api token to params
      params.merge!({ :token => self.token })

      # dispatch to the right method, with the full path (/api/v2 + endpoint)
      request = self.send("format_#{method}", "#{@url.path}/#{endpoint}", params)
      response = @http.request(request)
      
      # Possible Responses
      #
      # 200 - (OK) The request was received successfully.
      # 400 - (Bad Request) There was a problem with your request parameters. Check
      #       the error field of the response object for info on what was wrong.
      # 401 - (Unauthorized) Your API token in the token parameter was either missing
      #       or incorrect.
      # 404 - (Not Found) The API method was not found. Check yor request URL for
      #       typos.
      # 405 - (Method Not Allowed) An incorrect HTTP verb (i.e. GET, POST, etc) was
      #       used for the request
      # 5XX - There was an error Crocodoc could not recover from. We are generally
      #       notified of these automatically. If they are repeatedly received, you
      #       should contact Crocodoc Support.

      unless response.code == '200'
        raise Crocodoc::Error, "HTTP Error #{response.code}: #{response.body}"
      end
      response.body
    end


    # Internal: Format and create a Net::HTTP get request, with query
    # parameters.
    #
    # path - the path to get
    # params - the params to add as query params to the path
    #
    # Examples
    #
    #   format_get("/api/v2/document/status",
    #              { :token => <token>, :uuids => <uuids> })
    #   # => <Net::HTTP::Get:<id>> for
    #   #    "/api/v2/document/status?token=<token>&uuids=<uuids>"
    #
    # Returns a Net::HTTP::Get object for the path with query params
    def format_get(path, params)
      query = params.map { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&")
      Net::HTTP::Get.new("#{path}?#{query}")
    end

    # Internal: Format and create a Net::HTTP post request, with form
    # parameters.
    #
    # path - the path to get
    # params - the params to add as form params to the path
    #
    # Examples
    #
    #   format_post("/api/v2/document/upload",
    #              { :token => <token>, :url => <url> })
    #   # => <Net::HTTP::Post:<id>>
    #
    # Returns a Net::HTTP::Post object for the path with form params
    def format_post(path, params)
      Net::HTTP::Post.new(path).tap { |request| request.set_form_data(params) }
    end
  end
end
