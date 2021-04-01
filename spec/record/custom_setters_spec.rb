# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'custom setters' do
    context 'assigning values directly to other attributes' do
      before do
        Object.send(:remove_const, :Booking) if Object.const_defined?(:Booking) # make sure there is no other booking from previous tests around
        class Booking < DHS::Record
          endpoint 'https://bookings'

          def appointment_attributes=(params)
            self.appointments = params.map { |item| item[:id] }
          end
        end
      end

      it 'allows to change raw in custom setters' do
        booking = Booking.new(appointment_attributes: [{ id: 1 }])
        expect(booking.appointments.to_a).to eq [1]
      end
    end

    context 'assign values directly by using square brackets' do
      before do
        class Booking < DHS::Record
          endpoint 'https://bookings'

          def appointment_attributes=(params)
            self[:appointments] = params.map { |item| item[:id] }
          end
        end
      end

      it 'allows to change raw in custom setters' do
        booking = Booking.new(appointment_attributes: [{ id: 1 }])
        expect(booking.appointments.to_a).to eq [1]
      end
    end
  end
end
