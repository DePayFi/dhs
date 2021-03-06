# frozen_string_literal: true

require 'rails_helper'

describe DHS::Item do
  before do
    class Record < DHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    DHS::Data.new(json, nil, Record)
  end

  let(:item) do
    data[0]
  end

  context 'update' do
    it 'persists changes on the backend' do
      stub_request(:post, item.href)
        .with(body: item._raw.merge(name: 'Steve').to_json)
      result = item.update(name: 'Steve')
      expect(result).to eq true
    end

    it 'returns false if persisting went wrong' do
      stub_request(:post, item.href).to_return(status: 500)
      result = item.update(name: 'Steve')
      expect(result).to eq false
    end

    it 'merges reponse data with object' do
      stub_request(:post, item.href)
        .to_return(status: 200, body: item._raw.merge(likes: 'Banana').to_json)
      item.update(name: 'Steve')
      expect(item.likes).to eq 'Banana'
    end

    it 'updates local version of an object even if BE request fails' do
      stub_request(:post, item.href)
        .to_return(status: 400, body: item._raw.merge(likes: 'Banana').to_json)
      item.update(name: 'Andrea')
      expect(item.name).to eq 'Andrea'
      expect(item.likes).not_to eq 'Banana'
    end

    context 'with custom setters' do
      before do
        class Booking < DHS::Record
          endpoint 'http://bookings/bookings'

          def appointments=(appointments)
            super(
              appointments.map { |appointment| appointment[:id] }
            )
          end
        end
      end

      let(:item) do
        Booking.new(id: 'abc')
      end

      it 'updates data using custom setters before send to backend' do
        stub_request(:post, 'http://bookings/bookings')
          .with(body: {
            id: 'abc',
            appointments: [1, 2, 3]
          }.to_json)
          .to_return(status: 200)
        item.update(appointments: [{ id: 1 }, { id: 2 }, { id: 3 }])
        expect(item.appointments.to_a).to eq([1, 2, 3])
      end

      context 'with nested items' do
        before do
          class Booking < DHS::Record
            endpoint 'http://bookings/bookings'
            has_one :appointment_proposal
          end

          class AppointmentProposal < DHS::Record
            endpoint 'http://bookings/bookings'
            has_many :appointments

            def appointments_attributes=(attributes)
              self.appointments = attributes.map { |attribute| Appointment.new('date_time': attribute[:date]) }
            end
          end

          class Appointment < DHS::Record
          end
        end

        let(:item) do
          Booking.new(id: 'abc', appointment_proposal: { appointments: [] })
        end

        it 'updates data using custom setters before send to backend' do
          stub_request(:post, 'http://bookings/bookings')
            .with(body: {
              appointments: [{ date_time: '2018-01-18' }]
            }.to_json)
            .to_return(status: 200)
          item.appointment_proposal.update(appointments_attributes: [{ date: '2018-01-18' }])
          expect(item.appointment_proposal.appointments.as_json).to eq([{ 'date_time' => '2018-01-18' }])
        end
      end
    end

    context 'with many placeholders' do
      before do
        class GrandChild < DHS::Record
          endpoint 'http://host/v2/parents/{parent_id}/children/{child_id}/grand_children'
          endpoint 'http://host/v2/parents/{parent_id}/children/{child_id}/grand_children/{id}'
        end
      end

      let(:data) do
        {
          id: 'aaa',
          parent_id: 'bbb',
          child_id: 'ccc',
          name: 'Lorem'
        }
      end

      let(:item) do
        GrandChild.new(data)
      end

      it 'persists changes on the backend' do
        stub_request(:get, 'http://host/v2/parents/bbb/children/ccc/grand_children/aaa')
          .to_return(status: 200, body: data.to_json)
        stub_request(:post, 'http://host/v2/parents/bbb/children/ccc/grand_children/aaa')
          .with(body: { name: 'Steve' }.to_json)

        grand_child = GrandChild.find(parent_id: 'bbb', child_id: 'ccc', id: 'aaa')
        expect(grand_child.name).to eq('Lorem')
        result = grand_child.update(name: 'Steve')
        expect(result).to eq true
      end
    end
  end

  context 'update!' do
    it 'raises if something goes wrong' do
      stub_request(:post, item.href)
        .with(body: item._raw.merge(name: 'Steve').to_json)
        .to_return(status: 500)
      expect(-> { item.update!(name: 'Steve') }).to raise_error DHC::ServerError
    end
  end
end
