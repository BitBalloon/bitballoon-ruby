module BitBalloon
  class Model
    def self.fields(*names)
      return @@fields if names.empty?

      @@fields ||= []

      names.each do |name|
        define_method name do
          @attributes[name.to_sym]
        end

        define_method "#{name}=" do |value|
          @attributes[name.to_sym] = value
        end

        @@fields.push(name.to_sym)
      end
    end

    def initialize(attributes)
      @attributes = {}

      self.class.fields.each do |field|
        @attributes[field] = attributes[field] || attributes[field.to_s]
      end
    end
  end
end