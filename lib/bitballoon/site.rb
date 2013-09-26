module BitBalloon
  class Site < Model
    fields :id, :premium, :claimed, :name, :custom_domain, :url, :admin_url,
           :screenshot_url, :created_at, :updated_at, :user_id
  end
end