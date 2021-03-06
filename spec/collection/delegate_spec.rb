# frozen_string_literal: true

require 'rails_helper'

describe DHS::Collection do
  let(:data) do
    %w[ROLE_USER ROLE_LOCALCH_ACCOUNT]
  end

  let(:collection) do
    DHS::Collection.new(DHS::Data.new(data))
  end

  context 'delegates methods to raw' do
    %w(length size last sample present? blank? empty? compact).each do |method|
      it "delegates #{method} to raw" do
        expect(collection.send(method.to_sym)).not_to be_nil
      end
    end
  end
end
