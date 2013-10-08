require 'digest/sha1'
require 'uri'

module BitBalloon
  class Site < Model
    fields :id, :state, :premium, :claimed, :name, :custom_domain, :url,
           :admin_url, :deploy_url, :screenshot_url, :created_at, :updated_at,
           :password, :notification_email, :user_id, :required, :error_message

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
        client.request(:put, ::File.join(path, "files", URI.encode(shas[sha])), :body => ::File.read(::File.join(dir, shas[sha])), :headers => {"Content-Type" => "application/octet-stream"})
      end

      refresh
    end

    def ready?
      state == "current"
    end

    def error?
      state == "error"
    end

    def wait_for_ready(timeout = 900)
      start = Time.now
      while !(ready?)
        sleep 5
        refresh
        raise "Error processing site: #{error_message}" if error?
        yield(self) if block_given?
        raise "Timeout while waiting for ready" if Time.now - start > timeout
      end
      self
    end

    def update(attributes)
      if attributes[:zip] || attributes[:dir]
        site = collection.new(client).create(attributes.merge(:id => id))
        process(site.attributes)
      else
        response = client.request(:put, path, :body => mutable_attributes(attributes))
        process(response.parsed)
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