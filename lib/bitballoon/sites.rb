require "bitballoon/site"
require "digest/sha1"

module BitBalloon
  class Sites < CollectionProxy
    path "/sites"

    def create(attributes = {})
      response = client.request(:post, path, :body => Site.new(client, {}).send(:mutable_attributes, attributes))
      Site.new(client, response.parsed).tap do |site|
        if attributes[:zip] || attributes[:dir]
          deploy = site.deploys.create(attributes)
          site.deploy_id = deploy.id
        end
      end
    end
  end
end
