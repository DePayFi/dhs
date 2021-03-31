# frozen_string_literal: true

require 'active_support'

class DHS::Proxy

  module Link
    extend ActiveSupport::Concern

    private

    def record_from_link
      DHS::Record.for_url(_data.href)
    end

    def endpoint_from_link
      DHS::Endpoint.for_url(_data.href)
    end

    def params_from_link
      return {} if !_data.href || !endpoint_from_link
      DHC::Endpoint.values_as_params(endpoint_from_link.url, _data.href)
    end
  end
end
