# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'build' do
    let(:datastore) { 'http://depay.fi/v2' }

    it 'is possible to load records twice' do
      class Feedback < DHS::Record
        endpoint '{+datastore}/feedbacks'
      end

      class Feedback < DHS::Record
        endpoint '{+datastore}/feedbacks'
      end
    end
  end
end
