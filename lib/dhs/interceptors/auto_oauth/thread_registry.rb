# frozen_string_literal: true

require 'active_support'
require 'active_support/per_thread_registry'

module DHS
  module Interceptors
    module AutoOauth
      extend ActiveSupport::Concern
      class ThreadRegistry
        # Using ActiveSupports PerThreadRegistry to be able to support Active Support v4.
        # Will switch to thread_mattr_accessor (which comes with Activesupport) when we dropping support for Active Support v4.
        extend ActiveSupport::PerThreadRegistry
        attr_accessor :access_token
      end
    end
  end
end
