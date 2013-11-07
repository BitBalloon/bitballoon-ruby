module BitBalloon
  class User < Model
    fields :id, :uid, :email, :affiliate_id, :site_count, :created_at, :last_login

    def sites
      Sites.new(client, path)
    end

    def submissions
      Submissions.new(client, path)
    end

    def forms
      Forms.new(client, path)
    end
  end
end