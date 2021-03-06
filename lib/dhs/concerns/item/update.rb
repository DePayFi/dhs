# frozen_string_literal: true

require 'active_support'

class DHS::Item < DHS::Proxy
  autoload :EndpointLookup,
    'dhs/concerns/item/endpoint_lookup'

  module Update
    extend ActiveSupport::Concern

    included do
      include EndpointLookup
    end

    def update(params, options = nil, partial_update = false)
      update!(params, options, partial_update)
    rescue DHC::Error => e
      self.errors = DHS::Problems::Errors.new(e.response, record)
      false
    end

    def partial_update(params, options = nil)
      update(params, options, true)
    end

    def partial_update!(params, options = nil)
      update!(params, options, true)
    end

    def update!(params, options = {}, partial_update = false)
      options = options.present? ? options.dup : {}
      partial_record = _record.new(DHS::Data.new(params, _data.parent, _record))
      _data.merge_raw!(partial_record._data)
      data = _data._raw.dup
      partial_data = partial_record._data._raw.dup
      url = url_for_persistance!(data, options)
      data_sent = partial_update ? partial_data.extract!(*data.keys) : data
      response_data = record.request(
        options.merge(
          method: options.fetch(:method, :post),
          url: url,
          body: data_sent
        )
      )
      _data.merge_raw!(response_data.unwrap(:item_created_key))
      true
    end
  end
end
