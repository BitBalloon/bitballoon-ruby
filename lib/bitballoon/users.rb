require "bitballoon/user"

module BitBalloon
  class Users < CollectionProxy
    path "/users"
  end
end