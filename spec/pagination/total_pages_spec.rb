# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'pagination' do

    let(:page_1_json) do
      {
        items: [1, 2],
        total_pages: 3,
        page: 1,
        limit: 2
      }.to_json
    end

    let(:page_2_json) do
      {
        items: [3, 4],
        total_pages: 3,
        page: 2,
        limit: 2
      }.to_json
    end

    let(:page_3_json) do
      {
        items: [5, 6],
        total_pages: 3,
        page: 3,
        limit: 2
      }.to_json
    end

    before do
      class Feedback < DHS::Record
        configuration pagination_strategy: :total_pages, total_key: :total_pages, pagination_key: :page
        endpoint 'http://depay.fi/v2/feedbacks'
      end
      stub_request(:get, 'http://depay.fi/v2/feedbacks?limit=100').to_return(body: page_1_json)
      stub_request(:get, 'http://depay.fi/v2/feedbacks?limit=2&page=2').to_return(body: page_2_json)
      stub_request(:get, 'http://depay.fi/v2/feedbacks?limit=2&page=3').to_return(body: page_3_json)
    end

    it 'responds to limit_value' do
      feedbacks = Feedback.all.fetch
      expect(feedbacks.length).to eq 6
      expect(feedbacks.count).to eq 6
      expect(feedbacks.items.as_json).to eq [1, 2, 3, 4, 5, 6]
    end
  end
end
