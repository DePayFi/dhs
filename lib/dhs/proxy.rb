# frozen_string_literal: true

# Proxy makes different kind of data accessible
# If href is present it also alows loading/reloading
class DHS::Proxy
  autoload :Accessors,
    'dhs/concerns/proxy/accessors'
  autoload :Create,
    'dhs/concerns/proxy/create'
  autoload :Problems,
    'dhs/concerns/proxy/problems'
  autoload :Link,
    'dhs/concerns/proxy/link'

  include Accessors
  include Create
  include Link
  include Problems

  # prevent clashing with attributes of underlying data
  attr_accessor :_data, :_loaded
  delegate :_record, :becomes, to: :_data, allow_nil: true

  def initialize(data)
    self._data = data
    self._loaded = false
  end

  def record
    _data.class
  end

  def load!(options = nil)
    return self if _loaded
    reload!(options)
  end

  def reload!(options = nil)
    options = {} if options.blank?
    data = _data.class.request(
      options.merge(method: :get).merge(reload_options)
    )
    _data.merge_raw!(data.unwrap(:item_key))
    self._loaded = true
    return becomes(_record) if _record
    self
  end

  private

  def as_record
    @as_record ||= becomes(_record)
  end

  def reload_options
    return { url: _data.href } if _data.href
    return { params: { id: as_record.id } } if as_record.id
    {}
  end

  def merge_data_with_options(data, options)
    if options && options[:params]
      data.merge(options[:params])
    else
      data
    end
  end
end
