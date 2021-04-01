# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'to_json' do
    let(:datastore) { 'http://depay.fi/v2' }

    before do
      DHC.config.placeholder('datastore', datastore)
      class Feedback < DHS::Record
        endpoint '{+datastore}/feedbacks'
      end
    end

    it 'converts to json' do
      feedback = Feedback.new recommended: true
      expect(feedback.as_json).to eq('recommended' => true)
      expect(feedback.to_json).to eq('{"recommended":true}')
    end
  end
end
