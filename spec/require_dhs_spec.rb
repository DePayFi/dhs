# frozen_string_literal: true

describe DHS do
  context 'when requiring dhs' do
    it 'does not raise an exception' do
      expect { require 'dhs' }.not_to raise_error
    end
  end
end
