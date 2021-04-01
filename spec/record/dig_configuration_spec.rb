# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  before do
    class Business < DHS::Record
      configuration(
        items_key: %i[response businesses],
        total_key: %i[response count],
        limit_key: { body: %i[response max] },
        pagination_key: { body: %i[response offset] },
        pagination_strategy: :offset
      )
      endpoint 'http://uberall/businesses'
    end
  end

  let(:stub_single_business_request) do
    stub_request(:get, 'http://uberall/businesses?identifier=ABC123&limit=1')
      .to_return(body: {
        status: 'SUCCESS',
        response: {
          offset: 0,
          max: 50,
          count: 1,
          businesses: [
            {
              identifier: 'ABC123',
              name: 'depay'
            }
          ]
        }
      }.to_json)
  end

  let(:stub_multiple_businesses_request) do
    stub_request(:get, 'http://uberall/businesses?name=depay')
      .to_return(body: {
        status: 'SUCCESS',
        response: {
          offset: 0,
          max: 50,
          count: 2,
          businesses: [
            {
              identifier: 'ABC123',
              name: 'depay'
            },
            {
              identifier: 'ABC121',
              name: 'Swisscom'
            }
          ]
        }
      }.to_json)
  end

  context 'access nested keys for configuration' do
    it 'uses paths from configuration to access nested values' do
      stub_single_business_request
      business = Business.find_by(identifier: 'ABC123')
      expect(business.identifier).to eq 'ABC123'
      expect(business.name).to eq 'depay'
    end

    it 'digs for meta data when meta information is nested' do
      stub_multiple_businesses_request
      businesses = Business.where(name: 'depay')
      expect(businesses.length).to eq 2
      expect(businesses.count).to eq 2
      expect(businesses.offset).to eq 0
    end
  end
end
