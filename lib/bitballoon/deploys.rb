require "bitballoon/deploy"

module BitBalloon
  class Deploys < CollectionProxy
    path "/deploys"

    def create(attributes)
      if attributes[:dir]
        response = client.request(:post, path,
          :body => JSON.generate({:files => inventory(attributes[:dir]), :draft => attributes[:draft] || false}),
          :headers => {"Content-Type" => "application/json"}
        )
        Deploy.new(client, response.parsed).tap do |deploy|
          deploy.upload_dir(attributes[:dir])
        end
      elsif attributes[:zip]
        request_path = attributes[:draft] ? "#{path}?draft=true" : path
        response = client.request(:post, request_path,
          :body => ::File.read(attributes[:zip]),
          :headers => {"Content-Type" => "application/zip"}
        )
        Deploy.new(client, response.parsed)
      else
        raise "Need dir or zip to create a deploy"
      end
    end

    def draft(attributes)
      create(attributes.merge(:draft => true))
    end

    private
    def inventory(dir)
      files = {}
      Dir[::File.join(dir, "**", "*")].each do |file|
        next unless ::File.file?(file)
        path = ::File.join("/", file[dir.length..-1])
        files[path] = Digest::SHA1.hexdigest(::File.read(file))
      end
      files
    end
  end
end
