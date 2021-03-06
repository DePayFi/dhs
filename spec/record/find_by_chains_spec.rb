# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  before do
    class Record < DHS::Record
      endpoint 'http://datastore/records/'
    end
    stub_request(:get, 'http://datastore/records/?limit=1&name=Steve&color=blue')
      .to_return(body: [{ name: 'Steve', color: 'blue' }].to_json)
  end

  it 'allows chaining find_by' do
    Record.options(params: { color: 'blue' }).find_by(name: 'Steve')
  end

  it 'allows chaining find_by!' do
    Record.options(params: { color: 'blue' }).find_by!(name: 'Steve')
  end
end
