# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'pagination' do
    def stub_api_request(next_offset:, items: [], offset: nil)
      stub_request(:get, ['http://depay.fi/v2/transactions?limit=100', offset ? "offset=#{offset}" : nil].compact.join('&'))
        .to_return(body: { items: items, next_offset: next_offset }.to_json)
    end

    let!(:requests) do
      stub_api_request(items: (0...100).to_a, next_offset: 99)
      stub_api_request(items: (100...200).to_a, offset: 99, next_offset: 199)
      stub_api_request(items: (200...300).to_a, offset: 199, next_offset: 0)
    end

    before do
      class Transaction < DHS::Record
        configuration pagination_strategy: :next_offset, pagination_key: { body: :next_offset, parameter: :offset }

        endpoint 'http://depay.fi/v2/transactions'
      end
    end

    it 'fetches all the pages' do
      transactions = Transaction.all.fetch
      expect(transactions.to_a).to eq (0...300).to_a
    end
  end
end
