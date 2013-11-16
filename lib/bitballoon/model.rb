module BitBalloon
  class Model
    attr_reader :client, :attributes, :prefix

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
      @prefix = attributes.delete(:prefix)
      process(attributes)
    end

    def process(attributes)
      self.class.fields.each do |field|
        if attributes.has_key?(field) || attributes.has_key?(field.to_s)
          @attributes[field] = attributes[field] || attributes[field.to_s]
        end
      end
      self
    end

    def update(attributes)
      response = client.request(:put, path, :body => attributes)
      process(response.parsed) if response.parsed
    end

    def destroy
      client.request(:delete, path)
    end

    def refresh
      response = client.request(:get, path)
      process(response.parsed)
    end

    def collection
      self.class.collection
    end

    def path
      ::File.join(*[prefix, collection.path, id.to_s].compact)
    end
  end
end