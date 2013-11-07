require "bitballoon/site"
require "digest/sha1"

module BitBalloon
  class Sites < CollectionProxy
    path "/sites"

    def create(attributes = {})
      site_id = attributes.delete(:id)
      path    = site_id ? "/sites/#{site_id}" : "/sites"
      method  = site_id ? :put : :post
      if attributes[:dir]
        dir = attributes.delete(:dir)
        response = client.request(method, path, :body => JSON.generate(attributes.merge(:files => inventory(dir))), :headers => {"Content-Type" => "application/json"})
        Site.new(client, response.parsed).tap do |site|
          site.upload_dir(dir)
        end
      elsif attributes[:zip]
        zip = attributes.delete(:zip)
        ::File.open(zip) do |file|
          response = client.request(method, path, :body => attributes.merge(
            :zip => Faraday::UploadIO.new(file, 'application/zip')
          ))
          Site.new(client, response.parsed)
        end
      end
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