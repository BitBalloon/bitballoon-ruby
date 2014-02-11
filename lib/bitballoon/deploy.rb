module BitBalloon
  class Deploy < Model
    fields :id, :state, :premium, :claimed, :name, :custom_domain, :url,
           :admin_url, :deploy_url, :screenshot_url, :created_at, :updated_at,
           :user_id, :required

    def restore
      response = client.request(:post, ::File.join(path, "restore"))
      process(response.parsed)
      self
    end
  end
end