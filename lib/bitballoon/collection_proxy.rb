module BitBalloon
  class CollectionProxy
    include Enumerable

    attr_accessor :client

    def self.path(value = nil)
      return @@path unless value
      @@path = value
    end

    def self.model(value = nil)
      @@model ||= BitBalloon.const_get(to_s.split("::").last.sub(/s$/, ''))
    end

    def initialize(client)
      self.client = client
    end

    def all
      response = client.request(:get, path)
      response.parsed.map {|attributes| model.new(client, attributes) } if response.parsed
    end

    def each(&block)
      all.each(&block)
    end

    def get(id)
      response = client.request(:get, File.join(path, id))
      model.new(client, response.parsed) if response.parsed
    end

    def model
      self.class.model
    end

    def path
      self.class.path
    end
  end
end