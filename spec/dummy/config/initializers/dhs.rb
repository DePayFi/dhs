# frozen_string_literal: true

DHS.configure do |config|
  config.auto_oauth = -> { access_token }
end
