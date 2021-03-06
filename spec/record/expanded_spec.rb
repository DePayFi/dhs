# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  before do
    class Record < DHS::Record
      endpoint 'http://depay.fi/v2/records'
    end
  end

  let!(:request_collection) do
    stub_request(:get, 'http://depay.fi/v2/records?color=blue')
      .to_return(body: {
        items: [
          { href: 'http://depay.fi/v2/records/1' },
          { href: 'http://depay.fi/v2/records/2' }
        ]
      }.to_json)
  end

  let!(:request_item_1) do
    stub_request(:get, 'http://depay.fi/v2/records/1?via=collection')
      .to_return(body: {
        name: 'Steve'
      }.to_json)
  end

  let!(:request_item_2) do
    stub_request(:get, 'http://depay.fi/v2/records/2?via=collection')
      .to_return(body: {
        name: 'John'
      }.to_json)
  end

  it 'expands collections that just contains links' do
    records = Record.where(color: 'blue').expanded(params: { via: 'collection' })
    expect(records[0].name).to eq 'Steve'
    expect(records[1].name).to eq 'John'
    assert_requested request_collection
    assert_requested request_item_1
    assert_requested request_item_2
  end

  context 'without options' do
    let!(:request_item_1) do
      stub_request(:get, 'http://depay.fi/v2/records/1')
        .to_return(body: {
          name: 'Steve'
        }.to_json)
    end

    let!(:request_item_2) do
      stub_request(:get, 'http://depay.fi/v2/records/2')
        .to_return(body: {
          name: 'John'
        }.to_json)
    end

    it 'works also without options' do
      records = Record.where(color: 'blue').expanded
      expect(records[0].name).to eq 'Steve'
      expect(records[1].name).to eq 'John'
      assert_requested request_collection
      assert_requested request_item_1
      assert_requested request_item_2
    end
  end
end
