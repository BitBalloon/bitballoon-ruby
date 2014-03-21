module BitBalloon
  class Form < Model
    fields :id, :site_id, :name, :paths, :submission_count, :fields, :created_at

    def submissions
      Submissions.new(client, path)
    end
  end
end
