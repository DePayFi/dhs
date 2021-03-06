# frozen_string_literal: true

require 'active_support'
require 'active_model'

class DHS::Record

  module Model
    extend ActiveSupport::Concern

    def to_model
      self
    end

    def persisted?
      href.present?
    end

    included do
      extend ActiveModel::Naming
    end
  end
end
