module BitBalloon
  class CollectionProxy
    attr_accessor :client

    def self.path(value = nil)
      return @@path unless value
      @@path = value
    end

    def self.model(value = nil)
      return @@model unless value
      @@model = value
    end

    def initialize(client)
      self.client = client
    end

    def all
      response = client.request(:get, path)
      response.parsed.map {|attributes| model.new(attributes) } if response.parsed
    end

    def get(id)
      response = client.request(:get, File.join(path, id))
      model.new(response.parsed) if response.parsed
    end

    def model
      self.class.model
    end

    def path
      self.class.path
    end
  end
end