module Nylas
  module Model
    # Stores the actual model data to allow for type casting and clean/dirty checking
    class Attributes
      attr_accessor :data, :attribute_definitions

      def initialize(attribute_definitions)
        @attribute_definitions = attribute_definitions
        @data = Registry.new(default_attributes)
      end

      def [](key)
        data[key]
      end

      def []=(key, value)
        data[key] = cast(key, value)
      end

      private def cast(key, value)
        attribute_definitions[key].cast(value)
      rescue TypeError => e
        raise TypeError, "#{key} #{e.message}"
      end

      # Merges data into the registry while casting input types correctly
      def merge(new_data)
        new_data.each do |attribute_name, value|
          self[attribute_name] = value
        end
      end

      def to_h(keys: attribute_definitions.keys)
        keys.each_with_object({}) do |key, casted_data|
          value = attribute_definitions[key].serialize(self[key])
          casted_data[key] = defaulted_value(value)
        end
      end

      def serialize(keys: attribute_definitions.keys)
        JSON.dump(to_h(keys: keys))
      end

      private def default_attributes
        attribute_definitions.keys.zip([]).to_h
      end

      private def defaulted_value(value)
        result = value unless value.nil? || (value.respond_to?(:empty?) && value.empty?)
        result ||= [] if value.is_a?(Array)
        result ||= "" unless [true, false].include?(value)
        result
      end
    end
  end
end
