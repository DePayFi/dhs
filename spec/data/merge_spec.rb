# frozen_string_literal: true

require 'rails_helper'

describe DHS::Data do
  before do
    class Record < DHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:data) do
    DHS::Data.new({ href: 'http://www.depay.fi/v2/stuff' }, nil, Record)
  end

  let(:loaded_data) do
    DHS::Data.new({ href: 'http://www.depay.fi/v2/stuff', id: '123123123' }, nil, Record)
  end

  context 'merging' do
    it 'merges data' do
      data.merge_raw!(loaded_data)
      expect(data.id).to eq loaded_data.id
    end
  end
end
