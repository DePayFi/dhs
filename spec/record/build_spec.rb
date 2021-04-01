# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'build' do
    let(:datastore) { 'http://depay.fi/v2' }

    before do
      DHC.config.placeholder('datastore', datastore)
      class Feedback < DHS::Record
        endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
      end
    end

    it 'builds a new item from scratch' do
      feedback = Feedback.build recommended: true
      expect(feedback).to be_kind_of Feedback
      expect(feedback.recommended).to eq true
      stub_request(:post, 'http://depay.fi/v2/feedbacks')
        .with(body: '{"recommended":true}')
      feedback.save
    end
  end
end
