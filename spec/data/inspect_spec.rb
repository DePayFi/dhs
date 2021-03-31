# frozen_string_literal: true

require 'rails_helper'

describe DHS::Data do
  context 'inspect' do
    def expect_inspect_to_look_like(data, string)
      expect(data.inspect).to eq string.gsub(/  +/, '').strip
    end

    before do
      class Record < DHS::Record
        endpoint 'http://depay.fi/records'
        endpoint 'http://depay.fi/records/{id}'
      end
    end

    let(:raw) do
      { pets: [
        {
          name: 'Steve',
          kind: {
            animal: {
              type: 'Monkey'
            }
          }
        }
      ] }
    end

    let(:record) do
      stub_request(:get, 'http://depay.fi/records/1').to_return(body: raw.to_json)
      Record.find(1)
    end

    let(:data) do
      DHS::Data.new(raw, nil, Record).pets.first
    end

    it 'prints inspected data on multiple lines' do
      expect_inspect_to_look_like data, %Q{
        Data of Record #{data.object_id}
        > pets > 0
        :name => \"Steve\"
        :kind => {:animal=>{:type=>\"Monkey\"}}
      }
    end

    context 'breadcrumb' do
      let(:data) { record.pets.first.kind.animal }

      it 'prints the breadcrumb that shows you the current location within the main record' do
        expect_inspect_to_look_like data, %Q{
          Data of Record #{data.object_id}
          > pets > 0 > kind > animal
          :type => \"Monkey\"
        }
      end
    end

    context 'href as id' do
      let(:href) { 'http://datastore/places/1' }
      let(:raw) { { href: href, items: [{ name: 'Steve' }] } }
      let(:data) { record.first }

      it 'prints href as object id' do
        expect_inspect_to_look_like data, %Q{
          Record #{href}
          :name => \"Steve\"
        }
      end
    end

    context 'id attribute as id' do
      let(:id) { 1 }
      let(:raw) { { id: id, name: 'Steve' } }
      let(:data) { record }

      it 'prints id attribute as object id' do
        expect_inspect_to_look_like data, %Q{
          Record #{id}
          :id => 1
          :name => \"Steve\"
        }
      end
    end
  end
end
