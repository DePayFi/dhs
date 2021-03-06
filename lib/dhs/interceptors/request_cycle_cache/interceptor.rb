# frozen_string_literal: true

require 'active_support'

module DHS
  module Interceptors
    module RequestCycleCache
      extend ActiveSupport::Concern

      class Interceptor < DHC::Interceptor

        VERSION = 1
        CACHED_METHODS = [:get].freeze

        def before_request
          request.options = {
            cache: {
              expires_in: 5.minutes,
              race_condition_ttl: 5.seconds,
              key: cache_key_for(request),
              methods: CACHED_METHODS,
              use: DHS.config.request_cycle_cache
            }
          }.merge(request.options)
        end

        private

        def cache_key_for(request)
          [
            "DHS_REQUEST_CYCLE_CACHE(v#{VERSION})",
            request.method.upcase,
            [request.url, request.params.presence].compact.join('?'),
            "REQUEST=#{DHS::Interceptors::RequestCycleCache::ThreadRegistry.request_id}",
            "HEADERS=#{request.headers.hash}"
          ].join(' ')
        end
      end
    end
  end
end
