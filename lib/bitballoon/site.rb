require 'digest/sha1'

module BitBalloon
  class Site < Model
    fields :id, :state, :premium, :claimed, :name, :custom_domain, :url,
           :admin_url, :screenshot_url, :created_at, :updated_at, :user_id,
           :required

    def upload_dir(dir)
      return unless state == "uploading"

      shas = {}
      Dir[::File.join(dir, "**", "*")].each do |file|
        next unless ::File.file?(file)
        pathname = ::File.join("/", file[dir.length..-1])
        next if pathname.match(/(^\/?__MACOSX\/|\/\.)/)
        shas[Digest::SHA1.hexdigest(::File.read(file))] = pathname
      end

      (required || []).each do |sha|
        client.request(:put, ::File.join(path, "files", shas[sha]), :body => ::File.read(::File.join(dir, shas[sha])))
      end

      refresh
    end

    def ready?
      state == "ready"
    end

    def wait_for_ready(timeout = 900)
      start = Time.now
      while !ready?
        sleep 5
        refresh
        yield(self) if block_given?
        raise "Timeout while waiting for ready" if Time.now - start > timeout
      end
      self
    end

    def update(attributes)
      raise "Not implemented yet"
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
  end
end