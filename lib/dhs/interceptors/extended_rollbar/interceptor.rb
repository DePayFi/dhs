# frozen_string_literal: true

require 'active_support'

module DHS
  module Interceptors
    module ExtendedRollbar
      extend ActiveSupport::Concern

      class Interceptor < DHC::Interceptor
        def after_response
          return unless DHS::Interceptors::ExtendedRollbar::ThreadRegistry.log
          DHS::Interceptors::ExtendedRollbar::ThreadRegistry.log.push(request: request, response: response)
        end
      end
    end
  end

  const_set('ExtendedRollbar', DHS::Interceptors::ExtendedRollbar::Interceptor)
end
