# frozen_string_literal: true

require 'rails_helper'

describe DHS::Data do
  let(:raw) do
    { labels: { de: %w[cat dog] } }
  end

  let(:data) do
    DHS::Data.new(raw, nil, Record)
  end

  before do
    class Record < DHS::Record
      endpoint '{+datastore}/v2/data'
    end
  end

  context 'select' do
    it 'works with select' do
      expect(
        data.labels.de.select { |x| x }.join
      ).to eq 'catdog'
    end
  end
end
