# frozen_string_literal: true

require 'rails_helper'

describe DHS::Item do
  before do
    class Record < DHS::Record
    end
  end

  subject { Record.new }

  context 'add error' do
    it 'allows to add validation errors to the instance itself' do
      subject.errors.add(:name, 'This date is invalid')
      expect(
        subject.errors.first
      ).to eq ['name', 'This date is invalid']
    end
  end
end
