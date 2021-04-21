# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'pagination' do

    def stub_api_request(items:[], page: nil)
      stub_request(:get, ["http://depay.fi/v2/transactions?limit=100", page].compact.join('&page='))
        .to_return(body: { items: items }.to_json)
    end

    let!(:requests) do
      stub_api_request(items: (0...100).to_a)
      stub_api_request(items: (100...200).to_a, page: 1)
      stub_api_request(items: (200...300).to_a, page: 2)
      stub_api_request(items: [], page: 3)
    end

    before do
      class Transaction < DHS::Record
        configuration pagination_strategy: :offset_page, pagination_key: :page
        
        endpoint 'http://depay.fi/v2/transactions'
      end
    end

    it 'fetches all the pages' do
      transactions = Transaction.all.fetch
      expect(transactions.to_a).to eq (0...300).to_a
    end

    context 'incomplete pages' do
      let!(:requests) do
        stub_api_request(items: (0...100).to_a)
        stub_api_request(items: (100...200).to_a, page: 1)
        stub_api_request(items: (200...300).to_a, page: 2)
        stub_api_request(items: [300], page: 3)
        stub_api_request(items: [], page: 4)
      end

      it 'fetches all the pages' do
        transactions = Transaction.all.fetch
        expect(transactions.to_a).to eq (0..300).to_a
      end
    end

    context 'incomplete pages' do
      let!(:requests) do
        stub_api_request(items: (0...100).to_a)
        stub_api_request(items: (100...200).to_a, page: 1)
        stub_api_request(items: (200...299).to_a, page: 2)
        stub_api_request(items: [], page: 3)
      end

      it 'fetches all the pages' do
        transactions = Transaction.all.fetch
        expect(transactions.to_a).to eq (0...299).to_a
      end
    end
  end
end
