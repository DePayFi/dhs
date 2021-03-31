# frozen_string_literal: true

require 'active_support'

module DHS
  module OAuth
    extend ActiveSupport::Concern

    included do
      prepend_before_action :dhs_store_oauth_access_token
    end

    private

    def dhs_store_oauth_access_token
      dhs_check_auto_oauth_enabled!
      DHS::Interceptors::AutoOauth::ThreadRegistry.access_token = instance_exec(&DHS.config.auto_oauth)
    end

    def dhs_check_auto_oauth_enabled!
      return if DHS.config.auto_oauth.present? && DHS.config.auto_oauth.is_a?(Proc)
      raise 'You have to enable DHS.config.auto_oauth by passing a proc returning an access token!'
    end
  end
end
