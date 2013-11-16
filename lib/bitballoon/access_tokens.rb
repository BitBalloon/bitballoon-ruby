require "bitballoon/access_token"

module BitBalloon
  class AccessTokens < CollectionProxy
    path "/access_tokens"
  end
end