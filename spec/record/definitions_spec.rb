# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'definitions' do
    let(:datastore) { 'http://depay.fi/v2' }

    before do
      DHC.config.placeholder('datastore', datastore)
      class LocalEntry < DHS::Record
        endpoint '{+datastore}/local-entries'
        endpoint '{+datastore}/local-entries/{id}'
      end
    end

    it 'allows mappings in all functions/defitions' do
      class LocalEntry < DHS::Record
        def name
          addresses.first.business.identities.first.name
        end
      end
      stub_request(:get, "#{datastore}/local-entries/1")
        .to_return(status: 200, body: { addresses: [{ business: { identities: [{ name: 'Löwenzorn' }] } }] }.to_json)
      entry = LocalEntry.find(1)
      expect(entry.name).to eq 'Löwenzorn'
    end
  end
end
