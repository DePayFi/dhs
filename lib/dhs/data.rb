# frozen_string_literal: true

# Data provides functionalities to accesses information
class DHS::Data
  autoload :Becomes,
    'dhs/concerns/data/becomes'
  autoload :Equality,
    'dhs/concerns/data/equality'
  autoload :Extend,
    'dhs/concerns/data/extend'
  autoload :Json,
    'dhs/concerns/data/json'
  autoload :ToHash,
    'dhs/concerns/data/to_hash'

  include Becomes
  include Equality
  include Extend
  include Json
  include ToHash
  include DHS::Inspect

  delegate :instance_methods, :items_key, :limit_key, :total_key, :pagination_key, to: :class

  # prevent clashing with attributes of underlying data
  attr_accessor :_proxy, :_parent, :_record, :_request, :_endpoint
  attr_reader :_raw

  def initialize(input, parent = nil, record = nil, request = nil, endpoint = nil)
    self._raw = raw_from_input(input)
    self._parent = parent
    self._record = record
    self._proxy = proxy_from_input(input)
    self._request = request
    self._endpoint = endpoint
    preserve_input_requests!(input)
  end

  # merging data
  # e.g. when loading remote data via link
  def merge_raw!(data)
    return false if data.blank? || !data._raw.is_a?(Hash)
    _raw.merge! data._raw
  end

  # Unwraps data for certain use cases
  # like items_created_key for CREATE, UPDATED etc.
  # like item_key for GET etc.
  def unwrap(usecase)
    nested_path = record.send(usecase) if record
    return DHS::Data.new(dig(*nested_path) || _raw, nil, self.class) if nested_path
    self
  end

  def _root
    root = self
    root = root._parent while root&._parent
    root
  end

  def parent
    if _parent&._record
      _parent._record.new(_parent, false)
    else
      _parent
    end
  end

  def class
    _record || _root._record
  end

  # enforce internal data structure to have deep symbolized keys
  def _raw=(raw)
    raw.to_hash.deep_symbolize_keys! if raw&.respond_to?(:to_hash)
    @_raw = raw
  end

  def root_item?
    root_item == self
  end

  def collection?
    _proxy.is_a? DHS::Collection
  end

  def item?
    _proxy.is_a? DHS::Item
  end

  protected

  def method_missing(name, *args, **keyword_args, &block)
    _proxy.send(name, *args, **keyword_args, &block)
  end

  def respond_to_missing?(name, include_all = false)
    (root_item? && instance_methods.include?(name)) ||
      _proxy.respond_to?(name, include_all)
  end

  private

  def preserve_input_requests!(input)
    if input.is_a?(DHS::Data)
      _request = input._request if _request.nil?
    elsif input.is_a?(Array) && input.first.is_a?(DHS::Data)
      input.each_with_index do |item, index|
        next if item.nil?
        self[index]._request = item._request
      end
    end
  end

  def collection_proxy?(input)
    (input.is_a?(Hash) && DHS::Collection.access(input: input, record: _record)) ||
      input.is_a?(Array) ||
      _raw.is_a?(Array)
  end

  def root_item
    return if _proxy.class != DHS::Item
    root = root_item = self
    loop do
      root = root._parent
      root_item = root if root && root._proxy.is_a?(DHS::Item)
      unless (root && root._parent)
        break
      end
    end
    root_item
  end

  def root?
    _root == self
  end

  def proxy_from_input(input)
    if input.is_a? DHS::Proxy
      input
    elsif collection_proxy?(raw_from_input(input))
      DHS::Collection.new(self)
    else
      DHS::Item.new(self)
    end
  end

  def raw_from_input(input)
    if json?(input)
      raw_from_json_string(input)
    elsif defined?(input._raw)
      input._raw
    elsif defined?(input._data)
      input._data._raw
    else
      raw_from_anything_else(input)
    end
  end

  def json?(input)
    input.is_a?(String) && !input.empty? && !!input.match(/^("|\[|'|\{)/)
  end

  def raw_from_json_string(input)
    json = JSON.parse(input)
    if json.is_a?(Hash)
      json.deep_symbolize_keys
    elsif json.is_a?(Array)
      json.map { |item| item.is_a?(Hash) ? item.deep_symbolize_keys : item }
    else
      json
    end
  end

  def raw_from_anything_else(input)
    input = input.to_hash if input.class != Hash && input.respond_to?(:to_hash)
    input.deep_symbolize_keys! if input.is_a?(Hash)
    input
  end
end
