# frozen_string_literal: true

require 'rails_helper'

describe DHS::OptionBlocks do
  let(:status) { 200 }

  before do
    class Record < DHS::Record
      endpoint 'http://records'
    end

    stub_request(:get, 'http://records/?id=1234')
      .with(headers: { 'Tracking-Id' => 1 })
      .to_return(status: status)
  end

  it 'allows to apply options to all requests made within a certain block' do
    DHS.options(headers: { 'Tracking-Id': 1 }) do
      Record.find(1234)
    end
  end

  it 'ensures that option blocks are reset after the block has been executed' do
    expect(DHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
    DHS.options(headers: { 'Tracking-Id': 1 }) do
      Record.find(1234)
    end
    expect(DHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
  end

  context 'failing request' do
    let(:status) { 400 }

    it 'ensures that option blocks are reset when an exception occures in the block' do
      expect(DHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
      DHS.options(headers: { 'Tracking-Id': 1 }) do
        begin
          Record.find(1234)
        rescue DHC::Error
        end
      end
      expect(DHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
    end
  end

  context 'parallel requests' do
    it 'does not fail merging option blocks for parallel requests' do
      DHS.options(headers: { 'Tracking-Id': 1 }) do
        Record.find(1234, 1234)
      end
    end
  end
end
