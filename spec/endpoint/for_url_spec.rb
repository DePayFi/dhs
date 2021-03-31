# frozen_string_literal: true

require 'rails_helper'

describe DHS::Endpoint do
  context 'for url' do
    before do
      class Record < DHS::Record
        endpoint '{+datastore}/entries/{entry_id}/content-ads/{campaign_id}/feedbacks'
        endpoint '{+datastore}/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
      end
    end

    it 'provides the endpoint for a given url' do
      expect(
        DHS::Endpoint.for_url('http://depay.fi/v2/entries/123/content-ads/456/feedbacks').url
      ).to eq '{+datastore}/entries/{entry_id}/content-ads/{campaign_id}/feedbacks'
      expect(
        DHS::Endpoint.for_url('http://depay.fi/123/feedbacks').url
      ).to eq '{+datastore}/{campaign_id}/feedbacks'
      expect(
        DHS::Endpoint.for_url('http://depay.fi/feedbacks').url
      ).to eq '{+datastore}/feedbacks'
    end
  end
end
