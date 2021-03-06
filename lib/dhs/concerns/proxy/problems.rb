# frozen_string_literal: true

require 'active_support'

class DHS::Proxy

  module Problems
    extend ActiveSupport::Concern

    included do
      attr_writer :errors, :warnings
    end

    def initialize(data)
      super(data)
    end

    def errors
      response = (_raw.present? && _raw.is_a?(Hash) && _raw[:field_errors]) ? OpenStruct.new(body: _raw.to_json) : nil
      @errors ||= DHS::Problems::Errors.new(response, record)
    end

    def warnings
      @warnings ||= DHS::Problems::Warnings.new(_raw, record)
    end
  end
end
