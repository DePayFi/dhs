# frozen_string_literal: true

require 'dhs'
require 'dhs/test/stubbable_records'

RSpec.configure do |config|
  config.before(:each) do
    DHS.config.request_cycle_cache.clear
  end
end
