require "bitballoon/site"
require "digest/sha1"

module BitBalloon
  class Sites < CollectionProxy
    path "/sites"

    def create(attributes = {})
      if attributes[:dir]
        dir = attributes[:dir]
        response = client.request(:post, "/sites", :body => JSON.generate({:files => inventory(dir)}), :headers => {"Content-Type" => "application/json"})
        Site.new(client, response.parsed).tap do |site|
          site.upload_dir(dir)
        end
      elsif attributes[:zip]
        ::File.open(attributes[:zip]) do |file|
          response = client.request(:post, "/sites", :body => {
            :zip => Faraday::UploadIO.new(file, 'application/zip')
          })
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