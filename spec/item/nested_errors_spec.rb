# frozen_string_literal: true

require 'rails_helper'

describe DHS::Item do
  context 'nested data' do
    before do
      class Presence < DHS::Record
        endpoint 'http://opm/presences'
      end
      stub_request(:post, 'http://opm/presences')
        .to_return(
          body: {
            listings: [{ status: 'CONNECTED' }],
            field_errors: []
          }.to_json
        )
    end

    it 'does not raise when accessing nested data' do
      presence = Presence.create
      expect(lambda {
        presence.listings.first
      }).not_to raise_error NoMethodError
    end
  end
end
