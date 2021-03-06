# frozen_string_literal: true

require 'rails_helper'

describe DHS::Collection do
  let(:datastore) { 'http://depay.fi/v2' }
  let(:items) { [{ name: 'Steve' }] }
  let(:collection) { Account.where }

  before do
    DHC.config.placeholder('datastore', datastore)
    class Account < DHS::Record
      endpoint '{+datastore}/accounts'
    end
    stub_request(:get, 'http://depay.fi/v2/accounts')
      .to_return(body: response_data.to_json)
  end

  context 'plain array' do
    let(:response_data) do
      items
    end

    it 'initalises a collection' do
      expect(collection.first.name).to eq 'Steve'
    end

    it 'casts items to be instance of defined DHS::Record' do
      expect(collection.first).to be_kind_of Account
    end
  end

  context 'items key' do
    let(:response_data) do
      {
        items: items
      }
    end

    it 'initalises a collection when reponse contains a key items containing an array of items' do
      expect(collection.first.name).to eq 'Steve'
    end
  end
end
