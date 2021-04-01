# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)
require 'dhs'

module Dummy
  class Application < Rails::Application
  end
end
