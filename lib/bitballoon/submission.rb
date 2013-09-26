module BitBalloon
  class Submission < Model
    fields :id, :number, :title, :email, :name, :first_name, :last_name,
               :company, :summary, :body, :data, :created_at, :site_url
  end
end