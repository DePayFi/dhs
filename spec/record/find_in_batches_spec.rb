# frozen_string_literal: true

require 'rails_helper'

describe DHS::Collection do
  let(:total) { 443 }

  let(:limit) { 100 }

  def api_response(ids, offset, options = {})
    records = ids.map { |i| { id: i } }
    {
      options.fetch(:items_key, :items) => records,
      options.fetch(:total_key, :total) => total,
      options.fetch(:limit_key, :limit) => limit,
      options.fetch(:pagination_key, :offset) => offset
    }.to_json
  end

  let(:datastore) { 'http://depay.fi/v2' }

  before do
    DHC.config.placeholder('datastore', datastore)
    class Record < DHS::Record
      endpoint '{+datastore}/{campaign_id}/feedbacks'
      endpoint '{+datastore}/feedbacks'
    end
  end

  context 'find_batches' do
    it 'processes records in batches' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=0").to_return(status: 200, body: api_response((1..100).to_a, 0))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100").to_return(status: 200, body: api_response((101..200).to_a, 100))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200").to_return(status: 200, body: api_response((201..300).to_a, 200))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=300").to_return(status: 200, body: api_response((301..400).to_a, 300))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=400").to_return(status: 200, body: api_response((401..total).to_a, 400))
      length = 0
      Record.find_in_batches do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of DHS::Collection
      end
      expect(length).to eq total
    end

    it 'adapts to backend max limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=230&offset=0").to_return(status: 200, body: api_response((1..100).to_a, 0))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100").to_return(status: 200, body: api_response((101..200).to_a, 100))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200").to_return(status: 200, body: api_response((201..300).to_a, 200))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=300").to_return(status: 200, body: api_response((301..400).to_a, 300))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=400").to_return(status: 200, body: api_response((401..total).to_a, 400))
      length = 0
      Record.find_in_batches(batch_size: 230) do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of DHS::Collection
      end
      expect(length).to eq total
    end

    it 'forwards offset' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=400").to_return(status: 200, body: api_response((401..total).to_a, 400))
      Record.find_in_batches(start: 400) do |records|
        expect(records.length).to eq(total - 400)
      end
    end
  end

  context 'configured pagination' do
    before do
      class Record < DHS::Record
        endpoint '{+datastore}/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
        configuration items_key: 'docs', limit_key: 'size', pagination_key: 'start', pagination_strategy: 'start', total_key: 'totalResults'
      end
    end

    let(:options) { { items_key: 'docs', limit_key: 'size', pagination_key: 'start', total_key: 'totalResults' } }

    it 'capable to do batch processing with configured pagination' do
      stub_request(:get, "#{datastore}/feedbacks?size=230&start=1").to_return(status: 200, body: api_response((1..100).to_a, 1, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=101").to_return(status: 200, body: api_response((101..200).to_a, 101, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=201").to_return(status: 200, body: api_response((201..300).to_a, 201, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=301").to_return(status: 200, body: api_response((301..400).to_a, 301, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=401").to_return(status: 200, body: api_response((401..total).to_a, 401, options))
      length = 0
      Record.find_in_batches(batch_size: 230) do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of DHS::Collection
      end
      expect(length).to eq total
    end
  end

  context 'pagination with nested response' do
    before do
      class Record < DHS::Record
        endpoint '{+datastore}/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
        configuration items_key: %i[response docs], limit_key: { body: %i[response size], parameter: :size }, pagination_key: { body: %i[response start], parameter: :start }, pagination_strategy: :start, total_key: %i[response totalResults]
      end
    end

    let(:options) { { items_key: 'docs', limit_key: 'size', pagination_key: 'start', total_key: 'totalResults' } }

    it 'capable to do batch processing with configured pagination' do
      stub_request(:get, "#{datastore}/feedbacks?size=230&start=1").to_return(status: 200, body: "{\"response\":#{api_response((1..100).to_a, 1, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=101").to_return(status: 200, body: "{\"response\":#{api_response((101..200).to_a, 101, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=201").to_return(status: 200, body: "{\"response\":#{api_response((201..300).to_a, 201, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=301").to_return(status: 200, body: "{\"response\":#{api_response((301..400).to_a, 301, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=401").to_return(status: 200, body: "{\"response\":#{api_response((401..total).to_a, 401, options)}}")
      length = 0
      Record.find_in_batches(batch_size: 230) do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of DHS::Collection
      end
      expect(length).to eq total
    end
  end

  context 'different pagination strategy' do
    before do
      class Transaction < DHS::Record
        endpoint 'https://api/transactions'
        configuration limit_key: :items_on_page, pagination_strategy: :total_pages, pagination_key: :page, items_key: :transactions, total_key: :total_pages
      end

      stub_request(:get, 'https://api/transactions?items_on_page=50&page=1')
        .to_return(body: {
          page: 1,
          total_pages: 2,
          items_on_page: 50,
          transactions: 50.times.map { |index| { id: index } }
        }.to_json)

      stub_request(:get, 'https://api/transactions?items_on_page=50&page=2')
        .to_return(body: {
          page: 2,
          total_pages: 2,
          items_on_page: 50,
          transactions: 22.times.map { |index| { id: 50 + index } }
        }.to_json)
    end

    it 'find in batches and paginates automatically even for different pagination strategies' do
      total = 0
      transactions = []

      Transaction.find_in_batches(batch_size: 50) do |batch|
        total += batch.length
        transactions << batch
      end

      expect(total).to eq(72)
      expect(transactions.flatten.as_json).to eq(72.times.map { |index| { id: index }.as_json })
    end
  end
end
