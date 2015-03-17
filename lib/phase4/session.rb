require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      our_cookie = false
      req.cookies.each do |cookie|
        if cookie.name == '_rails_lite_app'
          our_cookie = cookie
          break
        end
      end
      @cookie = our_cookie ? JSON.parse(our_cookie.value) : {}
    end

    def [](key)
      @cookie[key]
    end

    def []=(key, val)
      @cookie[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      json = @cookie.to_json
      cookie = WEBrick::Cookie.new('_rails_lite_app', json)
      res.cookies << cookie
    end
  end
end
