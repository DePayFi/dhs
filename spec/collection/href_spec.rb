# frozen_string_literal: true

require 'rails_helper'

describe DHS::Collection do
  let(:collection) do
    DHS::Collection.new(DHS::Data.new([]))
  end

  context 'array misses href' do
    it 'works with empty array' do
      expect(
        collection.href
      ).to eq nil
    end
  end
end
