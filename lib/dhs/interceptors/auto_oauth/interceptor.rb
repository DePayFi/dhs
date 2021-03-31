# frozen_string_literal: true

require 'active_support'

module DHS
  module Interceptors
    module AutoOauth
      extend ActiveSupport::Concern

      class Interceptor < DHC::Interceptor

        def before_request
          request.options[:auth] = { bearer: token }
        end

        def tokens
          @tokens ||= DHS::Interceptors::AutoOauth::ThreadRegistry.access_token
        end

        def token
          if tokens.is_a?(Hash)
            tokens.dig(
              request.options[:oauth] ||
              request.options[:record]&.auto_oauth
            )
          else
            tokens
          end
        end
      end
    end
  end
end
