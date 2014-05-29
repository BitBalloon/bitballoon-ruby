require 'digest/sha1'
require 'uri'

module BitBalloon
  class Site < Model
    fields :id, :state, :premium, :claimed, :name, :custom_domain, :url,
           :admin_url, :deploy_id, :deploy_url, :screenshot_url, :created_at, :updated_at,
           :password, :notification_email, :user_id, :error_message, :required

    def ready?
      state == "current"
    end

    def error?
      state == "error"
    end

    def wait_for_ready(timeout = 900, &block)
      deploy = deploys.get(deploy_id)
      raise "Error fetching deploy #{deploy_id}" unless deploy
      deploy.wait_for_ready(timeout, &block)
      self
    end

    def update(attributes)
      response = client.request(:put, path, :body => mutable_attributes(attributes))
      process(response.parsed)
      if attributes[:zip] || attributes[:dir]
        deploy = deploys.create(attributes)
        self.deploy_id = deploy.id
      end
      self
    end

    def destroy!
      client.request(:delete, path)
      true
    end

    def forms
      Forms.new(client, path)
    end

    def submissions
      Submissions.new(client, path)
    end

    def files
      Files.new(client, path)
    end

    def snippets
      Snippets.new(client, path)
    end

    def deploys
      Deploys.new(client, path)
    end

    private
    def mutable_attributes(attributes)
      Hash[*[:name, :custom_domain, :password, :notification_email].map {|key|
        if attributes.has_key?(key) || attributes.has_key?(key.to_s)
          [key, attributes[key] || attributes[key.to_s]]
        end
      }.compact.flatten]
    end
  end
end
