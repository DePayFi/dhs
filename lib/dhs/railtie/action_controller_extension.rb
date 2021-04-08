# frozen_string_literal: true

module DHS
  class Railtie < Rails::Railtie

    class ::ActionController::Base

      def initialize
        prepare_dhs_request_cycle_cache
        reset_option_blocks
        reset_extended_rollbar_request_logs
        super
      end

      private

      def prepare_dhs_request_cycle_cache
        return unless DHS.config.request_cycle_cache_enabled
        DHS::Interceptors::RequestCycleCache::ThreadRegistry.request_id = [Time.now.to_f, request.object_id].join('#')
      end

      def reset_option_blocks
        DHS::OptionBlocks::CurrentOptionBlock.options = nil
      end

      def reset_extended_rollbar_request_logs
        return unless defined?(::Rollbar)
        return unless DHC.config.interceptors.include?(DHS::Interceptors::ExtendedRollbar::Interceptor)
        DHS::Interceptors::ExtendedRollbar::ThreadRegistry.log = []
      end
    end

  end
end
