require 'digest/sha1'

module BitBalloon
  class Site < Model
    fields :id, :state, :premium, :claimed, :name, :custom_domain, :url,
           :admin_url, :screenshot_url, :created_at, :updated_at, :user_id,
           :required

    def upload_from(dir)
      return unless state == "uploading"

      shas = {}
      Dir[File.join(dir, "**", "*")].each do |file|
        next unless File.file?(file)
        pathname = File.join("/", file[dir.length..-1])
        shas[Digest::SHA1.hexdigest(File.read(file))] = pathname
      end

      (required || []).each do |sha|
        client.request(:put, File.join(path, "files", shas[sha]), :body => File.read(File.join(dir, shas[sha])))
      end

      response = client.request(:get, path)
      process(response.parsed)
      self
    end
  end
end