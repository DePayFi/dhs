# frozen_string_literal: true

require 'rails_helper'

describe DHS::Item do
  let(:datastore) { 'http://depay.fi/v2' }

  let(:error_format_fields) do
    {
      'status' => 400,
      'message' => 'ratings must be set when review or name or review_title is set | The property value is required; it cannot be null, empty, or blank.',
      'fields' => [
        {
          'name' => 'ratings',
          'details' => [{ 'code' => 'REQUIRED_PROPERTY_VALUE' }, { 'code' => 'UNSUPPORTED_PROPERTY_VALUE' }]
        }, {
          'name' => 'recommended',
          'details' => [{ 'code' => 'REQUIRED_PROPERTY_VALUE' }]
        }
      ]
    }
  end

  let(:error_format_field_errors) do
    {
      'status' => 400,
      'message' => 'Some data in the request body failed validation. Inspect the field errors for details.',
      'field_errors' => [{
        'code' => 'UNSUPPORTED_PROPERTY_VALUE',
        'path' => ['gender'],
        'message' => 'The property value is unsupported. Supported values are: FEMALE, MALE'
      }, {
        'code' => 'INCOMPLETE_PROPERTY_VALUE',
        'path' => ['gender'],
        'message' => 'The property value is incomplete. It misses some data'
      }, {
        'code' => 'INCOMPLETE_PROPERTY_VALUE',
        'path' => %w[contract entry_id],
        'message' => 'The property value is incomplete. It misses some data'
      }]
    }
  end

  let(:not_defined_error_format) do
    {
      'error' => 'missing_token',
      'error_description' => 'Bearer token is missing'
    }
  end

  let(:unparsable_error_body) do
    '<html></html>'
  end

  before do
    I18n.reload!
    I18n.backend.store_translations(:en, {}) if defined? translations
    DHC.config.placeholder(:datastore, datastore)
    class Record < DHS::Record
      endpoint '{+datastore}/{campaign_id}/feedbacks'
      endpoint '{+datastore}/feedbacks'
    end
  end

  context 'save failed' do
    let(:record) { Record.build(name: 'Steve') }

    it 'parses fields correctly when creation failed' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_fields.to_json)
      result = record.save
      expect(result).to eq false
      expect(record.errors).to be_present
      expect(record.errors.any?).to eq true
      expect(record.name).to eq 'Steve'
      expect(record.errors.include?(:ratings)).to eq true
      expect(record.errors.include?(:recommended)).to eq true
      expect(record.errors[:ratings]).to eq %w[REQUIRED_PROPERTY_VALUE UNSUPPORTED_PROPERTY_VALUE]
      expect(record.errors[:recommended]).to eq ['REQUIRED_PROPERTY_VALUE']
    end

    it 'allows accessing error messages as a hash with indifferent access' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_fields.to_json)
      record.save
      expect(record.errors.messages[:ratings]).to be_present
      expect(record.errors.messages['ratings']).to be_present
    end

    it 'parses field errors correctly when creation failed' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_field_errors.to_json)
      result = record.save
      expect(result).to eq false
      expect(record.errors).to be_present
      expect(record.errors.any?).to eq true
      expect(record.errors.include?(:gender)).to eq true
      expect(record.errors.include?(:"contract.entry_id")).to eq true
      expect(record.errors[:gender]).to eq %w[UNSUPPORTED_PROPERTY_VALUE INCOMPLETE_PROPERTY_VALUE]
      expect(record.errors[:"contract.entry_id"]).to eq ['INCOMPLETE_PROPERTY_VALUE']
    end

    it 'parses field errors correctly when exception in raised' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_fields.to_json)
      expect { record.save! }.to raise_error(DHC::BadRequest)
      expect(record.errors).to be_present
      expect(record.errors.any?).to eq true
      expect(record.name).to eq 'Steve'
      expect(record.errors.include?(:ratings)).to eq true
      expect(record.errors.include?(:recommended)).to eq true
      expect(record.errors[:ratings]).to eq %w[REQUIRED_PROPERTY_VALUE UNSUPPORTED_PROPERTY_VALUE]
      expect(record.errors[:recommended]).to eq ['REQUIRED_PROPERTY_VALUE']
    end
  end

  context 'raw error data' do
    it 'provides access to raw error data' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_field_errors.to_json)
      record = Record.build
      record.save
      expect(record.errors.raw).to be_present
      expect(record.errors.any?).to eq true
      json = JSON.parse(record.errors.raw)
      expect(json['status']).to be_present
      expect(json['message']).to be_present
      expect(json['field_errors']).to be_present
    end
  end

  context 'request fails with unformated error message' do
    it 'still tells us that there is an error' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: not_defined_error_format.to_json)
      record = Record.build
      record.name = 'Steve'
      result = record.save
      expect(result).to eq false
      expect(record.errors).to be_present
      expect(record.errors.any?).to eq true
      expect(record.errors['error']).to eq ['missing_token']
      expect(record.errors['error_description']).to eq ['Bearer token is missing']
    end
  end

  context 'empty error response body' do
    it 'still tells us that there is an error' do
      stub_request(:post, "#{datastore}/feedbacks").to_return(status: 400)
      record = Record.build
      record.name = 'Steve'
      result = record.save
      expect(result).to eq false
      expect(record.errors).to be_present
      expect(record.errors.any?).to eq true
      expect(record.errors['body']).to eq ['parse error']
    end
  end

  context 'unparsable error body' do
    it 'still tells us that there is an error' do
      stub_request(:post, "#{datastore}/feedbacks").to_return(status: 400, body: unparsable_error_body)
      record = Record.build
      record.name = 'Steve'
      result = record.save
      expect(result).to eq false
      expect(record.errors).to be_present
      expect(record.errors.any?).to eq true
      expect(record.errors['body']).to eq ['parse error']
    end
  end

  describe '#clear' do
    let(:record) { Record.build(name: 'Steve') }

    before do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_fields.to_json)
    end

    it 'resets all errors' do
      record.save
      expect(record.errors.any?).to eq true
      record.errors.clear
      expect(record.errors.any?).to eq false
    end
  end

  context 'nested data' do
    let(:body_with_errors) do
      {
        'status' => 400,
        'message' => 'Some data in the request body failed validation. Inspect the field errors for details.',
        'field_errors' => [{
          'code' => 'UNSUPPORTED_PROPERTY_VALUE',
          'path' => ['reviews', 0, 'name'],
          'message' => 'The property value is unsupported. Supported values are: FEMALE, MALE'
        }, {
          'code' => 'INCOMPLETE_PROPERTY_VALUE',
          'path' => %w[address street name],
          'message' => 'The property value is incomplete. It misses some data'
        }, {
          'code' => 'REQUIRED_PROPERTY_VALUE',
          'path' => %w[address street additional_line1],
          'message' => 'The property value is required'
        }]
      }
    end

    let(:record) do
      Record.build(
        reviews: [{ name: 123, suggested: false }],
        address: {
          additional_line1: '',
          street: {
            name: 'Förlib'
          }
        }
      )
    end

    let(:errrors) { record.errors }

    before do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: body_with_errors.to_json)
    end

    it 'forwards errors to nested data' do
      record.save
      expect(record.errors['address.street.name']).to include 'INCOMPLETE_PROPERTY_VALUE'
      expect(record.errors['reviews.0.name']).to include 'UNSUPPORTED_PROPERTY_VALUE'
      expect(record.address.errors).to be_present
      expect(record.address.errors['street.name']).to be_present
      expect(record.address.street.errors).to be_present
      expect(record.address.street.errors[:name]).to include 'INCOMPLETE_PROPERTY_VALUE'
      expect(record.reviews.errors).to be_present
      expect(record.reviews.first.errors).to be_present
      expect(record.reviews.first.errors[:name]).to include 'UNSUPPORTED_PROPERTY_VALUE'
      expect(record.reviews.last.errors).to be_present
      expect(record.reviews.last.errors[:name]).to include 'UNSUPPORTED_PROPERTY_VALUE'
    end

    context 'accessing no model' do
      it 'does not raise an error when trying to find error record model name' do
        expect(lambda do
          record.reviews.first.errors[:name]
        end).not_to raise_error
      end
    end

    it 'provides http status code for errors' do
      record.save
      expect(record.errors.status_code).to eq 400
    end

    context 'with general error fallback message configured' do
      before do
        I18n.reload!
        I18n.backend.store_translations(:en, YAML.safe_load(translation)) if translation.present?
      end

      let(:translation) do
        %q{
          dhs:
            errors:
              fallback_message: 'This value is wrong'
        }
      end

      it 'is capable to access errors/attributes that dont have any validation errors' do
        record.save
        expect(record.reviews.first.errors[:suggested]).to be_kind_of Array
        expect(record.reviews.first.errors[:suggested]).to be_empty
      end
    end
  end

  context 'forwards errors to nested data when associations are defined' do
    before do
      class AppointmentProposal < DHS::Record
        endpoint 'http://dataste/appointment_proposals'
        endpoint 'http://dataste/appointment_proposals/{id}'

        has_many :appointments
      end

      class Appointment < DHS::Record
      end

      stub_request(:get, 'http://dataste/appointment_proposals/1')
        .to_return(body: {
          appointments: [
            { 'date_time' => '13.12.2018' },
            { 'date_time' => '18.10.2028' }
          ]
        }.to_json)

      stub_request(:post, 'http://dataste/appointment_proposals')
        .to_return(
          status: 400,
          body: {
            field_errors: [{
              'code' => 'DATE_PROPERTY_NOT_IN_FUTURE',
              'path' => ['appointments', 0, 'date_time']
            }]
          }.to_json
        )
    end

    it 'translates errors automatically when they are around' do
      appointment_proposal = AppointmentProposal.find(1)
      appointment_proposal.update(
        'appointments_attributes' => {
          '0' => { 'date_time' => '13.12.2018' },
          '1' => { 'date_time' => '18.10.2028' }
        }
      )
      appointment_proposal.appointments
      appointment = appointment_proposal.appointments[0]
      expect(appointment.errors[:date_time]).to eq ['DATE_PROPERTY_NOT_IN_FUTURE']
    end
  end
end
