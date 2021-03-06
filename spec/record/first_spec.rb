# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  let(:datastore) { 'http://depay.fi/v2' }

  before do
    DHC.config.placeholder(:datastore, datastore)
    class Record < DHS::Record
      endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
      endpoint '{+datastore}/feedbacks'
    end
  end

  context 'first' do
    it 'finds a single record' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1")
        .to_return(status: 200, body: load_json(:feedback))
      record = Record.first
      expect(record).to be_kind_of Record
      expect(record.source_id).to be_present
    end

    it 'returns nil if no record was found' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1")
        .to_return(status: 404)
      expect(Record.first).to be_nil
    end
  end

  context 'first!' do
    it 'raises if nothing was found with parameters' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1")
        .to_return(status: 404)
      expect { Record.first! }.to raise_error DHC::NotFound
    end
  end
end
