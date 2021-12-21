# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module Update
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method :update, :create
        alias_method :update!, :create!
      end
    end
  end
end
