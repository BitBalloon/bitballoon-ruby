require 'oauth2'

module BitBalloon
  class Client
    ENDPOINT    = ENV['OAUTH_CLIENT_API_URL'] || 'https://www.bitballoon.com'
    API_VERSION = "v1"

    class BitBalloonError < StandardError; end
    class NotFoundError < BitBalloonError; end
    class ConnectionError < BitBalloonError; end
    class InternalServerError < BitBalloonError; end
    class AuthenticationError < BitBalloonError; end

    attr_accessor :client_id, :client_secret, :oauth, :access_token

    def initialize(options)
      self.client_id     = options[:client_id]
      self.client_secret = options[:client_secret]
      self.access_token  = options[:access_token]
      self.oauth         = OAuth2::Client.new(client_id, client_secret, :site => ENDPOINT, :connection_build => lambda {|f|
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
      })
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

    def forms
      Forms.new(self)
    end

    def submissions
      Submissions.new(self)
    end

    def request(verb, path, opts={}, &block)
      raise AuthenticationError, "Authorize with BitBalloon before making requests" unless oauth_token

      oauth_token.request(verb, ::File.join("/api", API_VERSION, path), opts, &block)
    rescue OAuth2::Error => e
      case e.response.status
      when 401
        raise AuthenticationError, message_for(e, "Authentication Error")
      when 404
        raise NotFoundError, message_for(e, "Not Found")
      when 500
        raise InternalServerError, message_for(e, "Internal Server Error")
      else
        raise BitBalloonError, message_for(e, "OAuth2 Error")
      end
    rescue Faraday::Error::ConnectionFailed => e
      raise ConnectionError, message_for(e, "Connection Error")
    end

    private
    def oauth_token
      @oauth_token ||= access_token && OAuth2::AccessToken.new(oauth, access_token)
    end

    def message_for(error, default)
      error.message.strip == "" ? default : error.message
    end
  end
end