module BitBalloon
  class Deploy < Model
    fields :id, :state, :premium, :claimed, :name, :custom_domain, :url,
           :admin_url, :deploy_url, :screenshot_url, :created_at, :updated_at,
           :user_id, :required

    def upload_dir(dir)
      return unless state == "uploading"

      shas = Hash.new { [] }
      glob = ::File.join(dir, "**", "*")

      Dir.glob(glob) do |file|
        next unless ::File.file?(file)
        pathname = ::File.join("/", file[dir.length..-1])
        next if pathname.match(/(^\/?__MACOSX\/|\/\.)/)
        sha = Digest::SHA1.hexdigest(::File.read(file))
        shas[sha] = shas[sha] + [pathname]
      end

      (required || []).each do |sha|
        shas[sha].each do |pathname|
          client.request(:put, ::File.join(path, "files", URI.encode(pathname)), :body => ::File.read(::File.join(dir, pathname)), :headers => {"Content-Type" => "application/octet-stream"})
        end
      end

      refresh
    end

    def wait_for_ready(timeout = 900)
      start = Time.now
      while !(ready?)
        sleep 5
        refresh
        puts "Got state: #{state}"
        raise "Error processing site: #{error_message}" if error?
        yield(self) if block_given?
        raise "Timeout while waiting for ready" if Time.now - start > timeout
      end
      self
    end

    def ready?
      state == "ready"
    end

    def error?
      state == "error"
    end

    def publish
      response = client.request(:post, ::File.join(path, "restore"))
      process(response.parsed)
      self
    end
    alias :restore :publish
  end
end
