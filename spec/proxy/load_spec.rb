# frozen_string_literal: true

require 'rails_helper'

describe DHS::Proxy do
  before do
    class Record < DHS::Record
      endpoint '{+datastore}/v2/feedbacks'
    end

    stub_request(:get, 'http://depay.fi/v2/content-ads/51dfc5690cf271c375c5a12d')
      .to_return(status: 200, body: load_json(:localina_content_ad))
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    DHS::Data.new(json, nil, Record)
  end

  let(:item) do
    data[0]
  end

  let(:link) do
    item.campaign
  end

  context 'load' do
    it 'is loading data remotely when not present yet' do
      expect(link.load!.id).to be_present
      expect(link.id).to be_present
    end

    it 'can be reloaded' do
      expect(link.load!.id).to be_present
      stub_request(:get, 'http://depay.fi/v2/content-ads/51dfc5690cf271c375c5a12d')
        .to_return(status: 404)
      expect(-> { link.reload!.id })
        .to raise_error DHC::NotFound
    end
  end

  context 'endpoint options' do
    before do
      class AnotherRecord < DHS::Record
        endpoint '{+datastore}/v2/feedbacks', params: { color: :blue }
      end
    end

    let(:record) do
      AnotherRecord.new(href: 'http://datastore/v2/feedbacks')
    end

    it 'applies endpoint options on load!' do
      stub_request(:get, 'http://datastore/v2/feedbacks?color=blue')
        .to_return(body: {}.to_json)
      record.load!
    end
  end

  context 'per request options' do
    let(:record) do
      Record.new(href: 'http://datastore/v2/feedbacks')
    end

    it 'applies options passed to load' do
      stub_request(:get, 'http://datastore/v2/feedbacks?color=blue')
        .to_return(body: {}.to_json)
      record.load!(params: { color: 'blue' })
    end
  end
end
