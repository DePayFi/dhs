# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'model_name' do
    before do
      class LocalEntry < DHS::Record
        endpoint '{+datastore}/local-entries'
      end
    end

    it 'provides a model name' do
      expect(LocalEntry.model_name.name).to eq 'LocalEntry'
    end
  end
end
