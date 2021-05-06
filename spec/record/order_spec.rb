# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do

  context 'order in where chains' do

    before do
      class Record < DHS::Record
        endpoint 'http://records'
      end
    end

    context 'single parameter for order' do
      before do
        stub_request(:get, "http://records/?color=blue&order[created_at]=desc")
          .to_return(body: [{ name: 'ordered by created_at desc' }].to_json)
      end

      it 'allows to add order params with .order' do
        records = Record.where(color: 'blue').order(created_at: :desc)
        expect(records.first.name).to eq 'ordered by created_at desc'
      end
    end

    context 'multiple parameters for order' do
      before do
        stub_request(:get, "http://records/?color=blue&order[name]=asc&order[created_at]=desc")
          .to_return(body: [{ name: 'ordered by name asc (implicitly) and created_at desc (explicitly)' }].to_json)
      end

      it 'allows to add order params with .order' do
        records = Record.where(color: 'blue').order(:name, created_at: :desc)
        expect(records.first.name).to eq 'ordered by name asc (implicitly) and created_at desc (explicitly)'
      end
    end
  end
end
