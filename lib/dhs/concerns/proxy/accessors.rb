# frozen_string_literal: true

require 'active_support'

class DHS::Proxy
  module Accessors
    extend ActiveSupport::Concern

    # Keywords that would not be forwarded via method missing
    # FIXME: Extend the set of keywords
    BLACKLISTED_KEYWORDS = %w(new proxy_association).freeze

    delegate :dig, :fetch, to: :_raw, allow_nil: true

    def clear_cache!
      @cache = nil
    end

    private

    def set(name, args)
      clear_cache!
      return set_attribute_directly(name, args.try(:first)) if name != :[]=
      key = args[0]
      value = args[1]
      _data._raw[key.to_sym] = value
    end

    def set_attribute_directly(name, value)
      key = name.to_s.gsub(/=$/, '')
      _data._raw[key.to_sym] = value
    end

    def get(name, *args)
      name = args.first if name == :[]
      value = _data._raw[name.to_s] if _data._raw
      if value.nil? && _data._raw.present? && _data._raw.is_a?(Hash)
        value = _data._raw[name.to_sym]
        value = _data._raw[name.to_s.classify.to_sym] if value.nil?
      end

      record = DHS::Record.for_url(value[:href]) if value.is_a?(Hash) && value[:href]
      access_item(value, record, name) ||
        access_collection(value, record, name) ||
        convert(value)
    end

    def accessing_item?(value, record)
      return false unless value.is_a?(Hash)
      return false if record && access(input: value, record: record).present?
      return false if !record && value[:items].present?
      true
    end

    def accessing_collection?(value, record)
      return true if value.is_a?(Array)
      return true if value.is_a?(Hash) && record && access(input: value, record: record).present?
      return true if value.is_a?(Hash) && !record && value[:items].present?
    end

    def convert(value)
      return value unless value.is_a?(String)
      if date_time?(value)
        Time.zone.parse(value)
      elsif date?(value)
        Date.parse(value)
      else
        value
      end
    end

    def access_item(value, record, name)
      return unless accessing_item?(value, record)
      wrap_return(value, record, name)
    end

    def access_collection(value, record, name)
      return unless accessing_collection?(value, record)
      collection_data = DHS::Data.new(value, _data)
      collection = DHS::Collection.new(collection_data)
      wrap_return(collection, record, name)
    end

    # Wraps the return value with a record class.
    # Adds errors and warnings if existing.
    # Returns plain data if no record class was found.
    def wrap_return(value, record, name, args = nil)
      name = args.first if name == :[]
      return value unless worth_wrapping?(value)
      data = (value.is_a?(DHS::Data) || value.is_a?(DHS::Record)) ? value : DHS::Data.new(value, _data, record, _request)
      data.errors = DHS::Problems::Nested::Errors.new(errors, name) if errors.any?
      data.warnings = DHS::Problems::Nested::Warnings.new(warnings, name) if warnings.any?
      if _record && _record._relations[name]
        klass = _record._relations[name][:record_class_name].constantize
        return cache.compute_if_absent(klass) do
          data.becomes(klass, errors: data.errors, warnings: data.warnings)
        end
      elsif record && !value.is_a?(DHS::Record)
        return data.becomes(record, errors: data.errors, warnings: data.warnings)
      end
      data
    end

    def worth_wrapping?(value)
      value.is_a?(DHS::Proxy)     ||
        value.is_a?(DHS::Data)    ||
        value.is_a?(DHS::Record)  ||
        value.is_a?(Hash)         ||
        value.is_a?(Array)
    end

    def date?(value)
      value[date_time_regex, :date].presence
    end

    def time?(value)
      value[date_time_regex, :time].presence
    end

    def date_time?(value)
      date?(value) && time?(value)
    end

    def date_time_regex
      /(?<date>\d{4}-\d{2}-\d{2})?(?<time>T\d{2}:\d{2}(:\d{2}(\.\d*.\d{2}:\d{2})*)?)?/
    end

    def cache
      @cache ||= Concurrent::Map.new
    end
  end
end
