# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'next parameter pagination' do  
    def stub_api_request(this_parameter:, next_parameter:, items: [])
      stub_request(:get, ['http://depay.fi/v2/transactions?limit=100', this_parameter ? "next=#{this_parameter}" : nil].compact.join('&'))
        .to_return(body: { items: items, next: next_parameter }.to_json)
    end

    let!(:requests) do
      stub_api_request(items: (0...100).to_a, this_parameter: nil, next_parameter: 'NEXT1')
      stub_api_request(items: (100...200).to_a, this_parameter: 'NEXT1', next_parameter: 'NEXT2')
      stub_api_request(items: nil, this_parameter: 'NEXT2', next_parameter: nil)
    end

    before do
      class Transaction < DHS::Record
        configuration pagination_strategy: :next_parameter, pagination_key: { body: :next, parameter: :next }

        endpoint 'http://depay.fi/v2/transactions'
      end
    end

    it 'fetches all the pages' do
      transactions = Transaction.all.fetch
      expect(transactions.to_a).to eq (0...200).to_a
    end
  end

  context 'next parameter pagination with items configuration and nil response' do
    def stub_api_request(this_parameter:, next_parameter:, items: [])
      stub_request(:get, ['http://depay.fi/v2/transactions?limit=100', this_parameter ? "next=#{this_parameter}" : nil].compact.join('&'))
        .to_return(body: { assets: items, next: next_parameter }.to_json)
    end

    let!(:requests) do
      stub_api_request(items: (0...100).to_a, this_parameter: nil, next_parameter: 'NEXT1')
      stub_api_request(items: (100...200).to_a, this_parameter: 'NEXT1', next_parameter: 'NEXT2')
      stub_api_request(items: nil, this_parameter: 'NEXT2', next_parameter: nil)
    end

    before do
      class Transaction < DHS::Record
        configuration items_key: :assets, pagination_strategy: :next_parameter, pagination_key: { body: :next, parameter: :next }

        endpoint 'http://depay.fi/v2/transactions'
      end
    end

    it 'fetches and merges all the assets/items' do
      transactions = Transaction.all.fetch
      expect(transactions.to_a).to eq (0...200).to_a
    end
  end
end
