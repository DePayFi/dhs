# frozen_string_literal: true

class DHS::Record

  module AttributeAssignment
    extend ActiveSupport::Concern

    def assign_attributes(new_attributes)
      unless new_attributes.respond_to?(:stringify_keys)
        raise ArgumentError, "When assigning attributes, you must pass a hash as an argument, #{new_attributes.class} passed."
      end
      return if new_attributes.empty?

      _assign_attributes(new_attributes)
    end

    private

    def _assign_attributes(attributes)
      attributes.each do |key, value|
        public_send(:"#{key}=", value)
      end
    end
  end
end
