# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  before do
    class Business < DHS::Record
      configuration item_created_key: [:response, :business], limit_key: [:response, :max], pagination_key: [:response, :offset], total_key: [:response, :count], pagination_strategy: :offset
      endpoint 'http://uberall/businesses'
    end
  end

  let(:stub_create_business_request) do
    stub_request(:post, "http://uberall/businesses")
      .to_return(body: {
        status: "SUCCESS",
        response: {
          business: {
            identifier: 'ABC123',
            name: 'depay',
            id: 239650
          }
        }
      }.to_json)
  end

  it 'uses paths from configuration to access nested values' do
    stub_create_business_request
    business = Business.create!(
      identifier: 'ABC123',
      name: 'depay'
    )
    expect(business.identifier).to eq 'ABC123'
    expect(business.name).to eq 'depay'
    expect(business.id).to eq 239650
  end
end
