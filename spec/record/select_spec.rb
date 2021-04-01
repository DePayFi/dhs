# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  let(:record) do
    DHS::Record.new(DHS::Data.new(%w[cat dog]))
  end

  context 'select' do
    it 'works with select' do
      expect(
        record.select { |x| x }.join
      ).to eq 'catdog'
    end
  end
end
