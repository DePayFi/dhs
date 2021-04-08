# frozen_string_literal: true

module DHS
  class Railtie < Rails::Railtie
    initializer 'dhs.hook_into_controller_initialization' do

      Rails.application.reloader.to_prepare do
        require_relative 'railtie/action_controller_extension'
      end
    end
  end
end
