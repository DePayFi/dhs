# frozen_string_literal: true

require 'rails_helper'

describe DHS::Item do
  before do
    class Record < DHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:data) do
    DHS::Data.new({ addresses: [{ business: { identities: [{ name: 'Löwenzorn' }] } }] }, nil, Record)
  end

  context 'item getter' do
    it 'returns a collection if you access an array' do
      expect(data.addresses).to be_kind_of(DHS::Data)
      expect(data.addresses._proxy).to be_kind_of(DHS::Collection)
      expect(data.addresses.first.business.identities.first.name).to eq 'Löwenzorn'
    end
  end
end
