# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do

  context 'tracing' do
    context 'with tracing enabled' do

      before do
        allow(DHS.config).to receive(:trace).and_return(true)
      end

      context 'with non-paginated methods' do

        let(:request) do
          stub_request(:get, "https://records/3jg781")
            .to_return(status: 204)
        end

        before do
          class Record < DHS::Record
            endpoint 'https://records'
          end

          expect(DHC).to receive(:request).with(anything) do |arguments|
            expect(arguments[:source]).to include(__FILE__)
            spy(:response)
          end
        end

        %w[find find_by find_by! first first! last!].each do |method|
          context method do
            it 'forwards tracing options to dhc' do
              Record.public_send(method, color: :blue)
            end
          end
        end
      end

      context 'with paginated method last' do

        before do
          class Place < DHS::Record
            endpoint 'http://datastore/places'
          end

          stub_request(:get, "http://datastore/places?limit=1")
            .to_return(
              body: {
                items:  [
                  { id: 'first-1', company_name: 'Localsearch AG' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )

          stub_request(:get, "http://datastore/places?limit=1&offset=499")
            .to_return(
              body: {
                items:  [
                  { id: 'last-500', company_name: 'Curious GmbH' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )

          expect(DHC).to receive(:request).and_call_original
          expect(DHC).to receive(:request).with(hash_including(params: { offset: 499, limit: 1 })) do |arguments|
            expect(arguments[:source]).to include(__FILE__)
            spy(:response)
          end
        end

        it 'forwards tracing options to dhc' do
          Place.last
        end
      end
    end

    context 'tracing disabled (default)' do
      context 'non-paginated methods' do

        before do
          class Record < DHS::Record
            endpoint 'https://records'
          end

          expect(DHC).to receive(:request).with(anything) do |arguments|
            expect(arguments).not_to include(:source)
            spy(:response)
          end
        end

        %w[find find_by find_by! first first! last!].each do |method|
          context method do
            it 'does not forward tracing options to dhc' do
              Record.public_send(method, color: :blue)
            end
          end
        end
      end

      context 'with paginated method last' do
        before do
          class Place < DHS::Record
            endpoint 'http://datastore/places'
          end

          stub_request(:get, "http://datastore/places?limit=1")
            .to_return(
              body: {
                items:  [
                  { id: 'first-1', company_name: 'Localsearch AG' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )

          stub_request(:get, "http://datastore/places?limit=1&offset=499")
            .to_return(
              body: {
                items:  [
                  { id: 'last-500', company_name: 'Curious GmbH' }
                ],
                total:  500,
                limit:  1,
                offset: 0
              }.to_json
            )
        end

        it 'does not forward tracing options to dhc' do
          # for first pagination requets (first-1)
          expect(DHC).to receive(:request).and_call_original

          # for second reques (last-500)
          expect(DHC).to receive(:request).with(hash_including(params: { offset: 499, limit: 1 })) do |arguments|
            expect(arguments).not_to include(:source)
            spy(:response)
          end

          Place.last
        end
      end
    end
  end
end
