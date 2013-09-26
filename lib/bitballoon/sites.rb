require "bitballoon/site"

module BitBalloon
  class Sites < CollectionProxy
    path "/sites"
    model Site
  end
end