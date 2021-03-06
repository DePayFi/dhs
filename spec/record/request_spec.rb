# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  before do
    class Record < DHS::Record
      endpoint 'http://datastore/feedbacks/{id}'
    end
  end

  context 'url pattern' do
    let(:datastore) { 'http://depay.fi/v2' }

    before do
      DHC.config.placeholder(:datastore, datastore)
      class Record < DHS::Record
        endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
      end
    end

    it 'is using params as query params explicitly when provided in params namespace' do
      request = stub_request(:get, "#{datastore}/content-ads/123/feedbacks?campaign_id=456").to_return(status: 200)
      Record.where(campaign_id: 123, params: { campaign_id: '456' }).to_a
      assert_requested(request)
    end
  end

  context '#convert_options_to_endpoint' do
    before do
      class Record < DHS::Record
        endpoint 'http://datastore/feedbacks/{id}', params: { tracking: 123 }
      end
    end

    it 'identifies endpoint by given url and merges back endpoint template parameters' do
      options = DHS::Record.send(:convert_options_to_endpoints, url: 'http://datastore/feedbacks/1')
      expect(options[:params][:id]).to eq '1'
      expect(options[:url]).to eq 'http://datastore/feedbacks/{id}'
    end

    it 'identifies endpoint by given url and merges back endpoint template parameters into an array, if array was given' do
      options = DHS::Record.send(:convert_options_to_endpoints, [{ url: 'http://datastore/feedbacks/1' }])
      expect(options[0][:params][:id]).to eq '1'
      expect(options[0][:url]).to eq 'http://datastore/feedbacks/{id}'
    end

    it 'returnes nil if endpoint was not found for the given url' do
      options = DHS::Record.send(:convert_options_to_endpoints, url: 'http://datastore/reviews/1')
      expect(options).to eq nil
    end
  end

  context '#extend_with_reference' do
    it 'extends given options with the one for the refernce' do
      options = DHS::Record.send(:extend_with_reference, { url: 'http://datastore/feedbacks/1' }, { auth: { bearer: '123' } })
      expect(options[:auth][:bearer]).to eq '123'
    end

    it 'extends given list of options with the one for the refernce' do
      options = DHS::Record.send(:extend_with_reference, [{ url: 'http://datastore/feedbacks/1' }], auth: { bearer: '123' })
      expect(options[0][:auth][:bearer]).to eq '123'
    end
  end

  context '#options_for_data' do
    it 'extract request options from raw data' do
      options = DHS::Record.send(:url_option_for, DHS::Data.new({ href: 'http://datastore/feedbacks/1' }, nil, Record))
      expect(options[:url]).to eq 'http://datastore/feedbacks/1'
    end

    it 'extract a list of request options from raw data if data is a collection' do
      options = DHS::Record.send(:url_option_for, DHS::Data.new({ items: [{ href: 'http://datastore/feedbacks/1' }] }, nil, Record))
      expect(options[0][:url]).to eq 'http://datastore/feedbacks/1'
    end

    it 'extract request options from raw nested data' do
      options = DHS::Record.send(:url_option_for, DHS::Data.new({ reviews: { href: 'http://datastore/reviews/1' } }, nil, Record), :reviews)
      expect(options[:url]).to eq 'http://datastore/reviews/1'
    end
  end

  context '#record_for_options' do
    it 'identifies dhs record from given options, as all request have to be done through DHS Records' do
      record = DHS::Record.send(:record_for_options, url: 'http://datastore/feedbacks/1')
      expect(record).to eq Record
    end
  end
end
