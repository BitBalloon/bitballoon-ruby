module BitBalloon
  class Model
    attr_reader :client

    def self.fields(*names)
      return @fields if names.empty?

      @fields ||= []

      names.each do |name|
        define_method name do
          @attributes[name.to_sym]
        end

        define_method "#{name}=" do |value|
          @attributes[name.to_sym] = value
        end

        @fields.push(name.to_sym)
      end
    end

    def self.collection(value = nil)
      @collection ||= BitBalloon.const_get(to_s.split("::").last + "s")
    end

    def initialize(client, attributes)
      @client = client
      @attributes = {}
      process(attributes)
    end

    def process(attributes)
      self.class.fields.each do |field|
        @attributes[field] = attributes[field] || attributes[field.to_s]
      end
      self
    end

    def refresh
      response = client.request(:get, path)
      process(response.parsed)
    end

    def collection
      self.class.collection
    end

    def path
      ::File.join(collection.path, id)
    end
  end
end