require 'oauth2'

module BitBalloon
  class Client
    ENDPOINT    = ENV['OAUTH_CLIENT_API_URL'] || 'https://www.bitballoon.com/api/v1'
    API_VERSION = "v1"

    attr_accessor :client_id, :client_secret, :oauth, :access_token

    def initialize(options)
      self.client_id     = options[:client_id]
      self.client_secret = options[:client_secret]
      self.access_token  = options[:access_token]
      self.oauth         = OAuth2::Client.new(client_id, client_secret, :site => ENDPOINT)
    end

    def authorize_url(options)
      oauth.auth_code.authorize_url(options)
    end

    def authorize_from_code!(authorization_code, options)
      @oauth_token = oauth.auth_code.get_token(authorization_code, options)
      self.access_token = oauth_token.token
    end

    def authorize_from_credentials!
      @oauth_token = oauth.client_credentials.get_token
      self.access_token = oauth_token.token
    end

    def sites
      Sites.new(self)
    end

    def request(verb, path, opts={}, &block)
      raise "Authorize with BitBalloon before making requests" unless oauth_token
      oauth_token.request(verb, File.join("/api", API_VERSION, path), opts, &block)
    end

    private
    def oauth_token
      @oauth_token ||= access_token && OAuth2::AccessToken.new(oauth, access_token)
    end
  end
end