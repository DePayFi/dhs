# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/module/attribute_accessors_per_thread'
module DHS
  module Interceptors
    module RequestCycleCache
      extend ActiveSupport::Concern
      class ThreadRegistry
        thread_mattr_accessor :request_id
      end
    end
  end
end
