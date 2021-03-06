# frozen_string_literal: true

require 'active_support'

class DHS::Item < DHS::Proxy

  module Validation
    extend ActiveSupport::Concern

    def valid?(options = {})
      options ||= {}
      errors.clear
      endpoint = validation_endpoint
      raise 'No endpoint found to perform validations! See here: https://github.com/DePayFi/dhs#validation' unless endpoint
      record = DHS::Record.for_url(endpoint.url)
      params = merge_validation_params!(endpoint).merge options.fetch(:params, {})
      url = validation_url(endpoint)
      run_validation!(record, options, url, params)
      true
    rescue DHC::Error => e
      self.errors = DHS::Problems::Errors.new(e.response, record)
      false
    end
    alias validate valid?

    private

    def validation_url(endpoint)
      url = endpoint.url
      action = endpoint.options[:validates][:path].presence
      url = "#{url}/#{action}" if action.present?
      url
    end

    def merge_validation_params!(endpoint)
      validates_params = endpoint.options[:validates].reject { |key, _| key.to_sym == :path }
      params = endpoint.options.fetch(:params, {}).merge(params_from_link)
      params = params.merge(validates_params) if validates_params.is_a?(Hash)
      params
    end

    def run_validation!(record, options, url, params)
      record.request(
        options.merge(
          url: url,
          method: :post,
          params: params,
          body: _data
        )
      )
    end

    def validation_endpoint
      endpoint = endpoint_from_link if _data.href # take embeded first
      endpoint ||= record.find_endpoint(_data._raw)
      validates = endpoint.options&.fetch(:validates, false)
      raise 'Endpoint does not support validations!' unless validates
      endpoint
    end
  end
end
