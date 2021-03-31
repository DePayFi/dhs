# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module FindBy
    extend ActiveSupport::Concern

    module ClassMethods
      # Fetch some record by parameters
      def find_by(params = {}, options = nil)
        _find_by(params, trace!(options))
      rescue DHC::NotFound
        nil
      end

      # Raise if no record was found
      def find_by!(params = {}, options = nil)
        _find_by(params, trace!(options))
      end

      private

      def _find_by(params, options = {})
        raise(DHS::Unprocessable.new, 'Cannot find Record without an ID') if params.any? && params.all? { |_, value| value.blank? }
        options ||= {}
        params = params.dup.merge(limit_key(:parameter) => 1).merge(options.fetch(:params, {}))
        data = request(options.merge(params: params))
        if data && data._proxy.is_a?(DHS::Collection)
          data.first || raise(DHC::NotFound.new('No item was found.', data._request.response))
        elsif data
          data._record.new(data.unwrap_nested_item)
        end
      end
    end
  end
end
