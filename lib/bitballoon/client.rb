require 'oauth2'

module BitBalloon
  class Client
    ENDPOINT    = ENV['OAUTH_CLIENT_API_URL'] || 'https://www.bitballoon.com'
    API_VERSION = "v1"
    RETRIES     = 3

    class BitBalloonError < StandardError; end
    class NotFoundError < BitBalloonError; end
    class ConnectionError < BitBalloonError; end
    class InternalServerError < BitBalloonError; end
    class AuthenticationError < BitBalloonError; end

    attr_accessor :client_id, :client_secret, :oauth, :access_token, :endpoint

    def initialize(options)
      self.client_id     = options[:client_id]
      self.client_secret = options[:client_secret]
      self.access_token  = options[:access_token]
      self.endpoint      = options[:endpoint] || ENDPOINT
      self.oauth         = OAuth2::Client.new(client_id, client_secret, :site => endpoint, :connection_build => lambda {|f|
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

    def users
      Users.new(self)
    end

    def dns_zones
      DnsZones.new(self)
    end

    def access_tokens
      AccessTokens.new(self)
    end

    def request(verb, path, opts={}, &block)
      retries = 0
      begin
        raise AuthenticationError, "Authorize with BitBalloon before making requests" unless oauth_token

        oauth_token.request(verb, ::File.join("/api", API_VERSION, path), opts, &block)
      rescue OAuth2::Error => e
        case e.response.status
        when 401
          raise AuthenticationError, message_for(e, "Authentication Error")
        when 404
          raise NotFoundError, message_for(e, "Not Found")
        when 500
          if retry_request?(verb, e.response.status, retries)
            retries += 1
            retry
          else
            raise InternalServerError, message_for(e, "Internal Server Error")
          end
        else
          raise BitBalloonError, message_for(e, "OAuth2 Error")
        end
      rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError, Timeout::Error => e
        if retry_request?(verb, e.response && e.response.status, retries)
          retries += 1
          retry
        else
          raise ConnectionError, message_for(e, "Connection Error")
        end
      end
    end

    private
    def retry_request?(http_verb, status_code, retries)
      return false unless [:get, :put, :delete, :head].include?(http_verb.to_s.downcase.to_sym)
      return retries < 3 unless status_code && status_code == 422
    end

    def oauth_token
      @oauth_token ||= access_token && OAuth2::AccessToken.new(oauth, access_token)
    end

    def message_for(error, default)
      error.message.strip == "" ? default : error.message
    end
  end
end
