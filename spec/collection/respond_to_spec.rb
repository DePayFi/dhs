# frozen_string_literal: true

require 'rails_helper'

describe DHS::Collection do
  let(:data) do
    %w[ROLE_USER ROLE_LOCALCH_ACCOUNT]
  end

  let(:collection) do
    DHS::Data.new(DHS::Data.new(data))
  end

  context '#respond_to?' do
    # In this case raw collection is an Array implementing first
    it 'forwards calls to raw collection' do
      expect(collection.respond_to?(:first)).to be(true)
    end
  end
end
