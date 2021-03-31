# frozen_string_literal: true

require 'active_support'

module DHS
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      def config
        DHS::Config.instance
      end

      def configure
        DHS::Config.instance.reset
        yield config
      end
    end
  end
end
