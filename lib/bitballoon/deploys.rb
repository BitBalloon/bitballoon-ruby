require "bitballoon/deploy"

module BitBalloon
  class Deploys < CollectionProxy
    path "/deploys"

    def create(attributes)
      response = nil
      if attributes[:dir]
        response = client.request(:post, path, :body => {:files => inventory(attributes[:dir])})
      elsif attributes[:zip]
        response = client.request(:post, path, :body => ::File.read(attributes[:zip]), :headers => {"Content-Type" => "application/zip"})
      else
        raise "Need dir or zip to create a deploy"
      end
      Deploy.new(client, response.parsed)

      #
      # site_id = attributes.delete(:id)
      # path    = site_id ? "/sites/#{site_id}" : "/sites"
      # method  = site_id ? :put : :post
      # if attributes[:dir]
      #   dir = attributes.delete(:dir)
      #   response = client.request(method, path, :body => JSON.generate(attributes.merge(:files => inventory(dir))), :headers => {"Content-Type" => "application/json"})
      #   Site.new(client, response.parsed).tap do |site|
      #     deploy = Deploy.new(client, :id => site.deploy_id, :required => site.required, :state => site.state)
      #     puts "Uploading dir"
      #     deploy.upload_dir(dir)
      #     site.refresh
      #   end
      # elsif attributes[:zip]
      #   zip = attributes.delete(:zip)
      #   ::File.open(zip) do |file|
      #     response = client.request(method, path, :body => attributes.merge(
      #       :zip => Faraday::UploadIO.new(file, 'application/zip')
      #     ))
      #     Site.new(client, response.parsed)
      #   end
      # end
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
