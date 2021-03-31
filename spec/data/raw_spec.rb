# frozen_string_literal: true

require 'rails_helper'

describe DHS::Data do
  before do
    class Record < DHS::Record
      endpoint '{+datastore}/v2/entries/{entry_id}/content-ads/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:data_from_raw) do
    DHS::Data.new({ href: 'http://www.depay.fi/v2/stuff', id: '123123123' }, nil, Record)
  end

  let(:data_from_item) do
    raw = { href: 'http://www.depay.fi/v2/stuff' }
    item = DHS::Item.new(DHS::Data.new(raw, nil, Record))
    DHS::Data.new(item)
  end

  let(:data_from_array) do
    DHS::Data.new([
      { href: 'http://www.depay.fi/v2/stuff/3', id: '123123123' },
      { href: 'http://www.depay.fi/v2/stuff/4', id: '123123124' }
    ].to_json)
  end

  context 'raw' do
    it 'you can access raw data that is underlying' do
      expect(data_from_raw._raw).to be_kind_of Hash
    end

    it 'forwards raw when you feed data with some DHS object' do
      expect(data_from_item._raw).to be_kind_of Hash
      expect(data_from_item._raw).to eq(
        href: 'http://www.depay.fi/v2/stuff'
      )
    end

    it 'returns a Hash with symbols when the input is an array' do
      expect(data_from_array._raw).to be_kind_of Array
      expect(data_from_array._raw.first.keys.first).to be_kind_of Symbol
    end
  end
end
