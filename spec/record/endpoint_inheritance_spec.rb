# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'inherit endpoints' do
    before do
      class Base < DHS::Record
        endpoint 'records/{id}'
      end

      class Example < Base
      end
    end

    it 'inherits endpoints based on ruby class_attribute behaviour' do
      request = stub_request(:get, 'http://records/1').to_return(body: [].to_json)
      Example.find(1)
      Base.find(1)
      assert_requested(request, times: 2)
    end
  end

  context 'define endpoints in subclass' do
    before do
      class Base < DHS::Record
        endpoint 'records/{id}'
      end

      class Example < Base
        endpoint 'records'
      end
    end

    it 'inherits endpoints based on ruby class_attribute behaviour' do
      stub_request(:get, 'http://records?color=blue').to_return(body: [].to_json)
      Example.where(color: 'blue')
      expect(
        -> { Base.all.first }
      ).to raise_error(RuntimeError, 'Compilation incomplete. Unable to find value for id.')
    end
  end

  context 'ambiguous endpoints between super and subclass' do
    before do
      class Base < DHS::Record
        endpoint 'records'
      end

      class Example < Base
        endpoint 'examples/{id}'
      end
    end

    it 'inherits endpoints based on ruby class_attribute behaviour' do
      request = stub_request(:get, 'http://records?limit=100').to_return(body: [].to_json)
      Base.all.first
      assert_requested(request)

      request = stub_request(:get, 'http://examples/1').to_return(body: {}.to_json)
      Example.find(1)
      assert_requested(request)
    end
  end
end
