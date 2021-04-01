# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  let(:handler) { spy('handler') }

  before do
    class Record < DHS::Record
      endpoint 'http://depay.fi/v2/records/{id}'
    end

    class NestedRecord < DHS::Record
      endpoint 'http://depay.fi/v2/other_records/{id}'
    end
    stub_request(:get, 'http://depay.fi/v2/records/1')
      .to_return(body: {
        href: 'http://depay.fi/v2/records/1',
        other: {
          href: 'http://depay.fi/v2/other_records/2'
        }
      }.to_json)
    stub_request(:get, 'http://depay.fi/v2/other_records/2')
      .to_return(status: 404)
  end

  it 'allows to pass error_handling for includes to DHC' do
    handler = ->(_) { return { deleted: true } }
    record = Record.includes_first_page(:other).references(other: { rescue: { DHC::NotFound => handler } }).find(id: 1)

    expect(record.other.deleted).to be(true)
  end
end
