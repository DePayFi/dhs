# frozen_string_literal: true

class DHS::Record
  autoload :AttributeAssignment,
    'dhs/concerns/record/attribute_assignment'
  autoload :Batch,
    'dhs/concerns/record/batch'
  autoload :Chainable,
    'dhs/concerns/record/chainable'
  autoload :Configuration,
    'dhs/concerns/record/configuration'
  autoload :Create,
    'dhs/concerns/record/create'
  autoload :CustomSetters,
    'dhs/concerns/record/custom_setters'
  autoload :Destroy,
    'dhs/concerns/record/destroy'
  autoload :Endpoints,
    'dhs/concerns/record/endpoints'
  autoload :Equality,
    'dhs/concerns/record/equality'
  autoload :Find,
    'dhs/concerns/record/find'
  autoload :FindBy,
    'dhs/concerns/record/find_by'
  autoload :First,
    'dhs/concerns/record/first'
  autoload :HrefFor,
    'dhs/concerns/record/href_for'
  autoload :Last,
    'dhs/concerns/record/last'
  autoload :Mapping,
    'dhs/concerns/record/mapping'
  autoload :Merge,
    'dhs/concerns/record/merge'
  autoload :Model,
    'dhs/concerns/record/model'
  autoload :Pagination,
    'dhs/concerns/record/pagination'
  autoload :Provider,
    'dhs/concerns/record/provider'
  autoload :Request,
    'dhs/concerns/record/request'
  autoload :Relations,
    'dhs/concerns/record/relations'
  autoload :Scope,
    'dhs/concerns/record/scope'
  autoload :Tracing,
    'dhs/concerns/record/tracing'
  autoload :Update,
    'dhs/concerns/record/update'

  include AttributeAssignment
  include Batch
  include Chainable
  include Configuration
  include Create
  include CustomSetters
  include Destroy
  include Endpoints
  include Equality
  include Find
  include FindBy
  include First
  include HrefFor
  include DHS::IsHref
  include Last
  include DHS::Inspect
  include Mapping
  include Merge
  include Model
  include Pagination
  include Provider
  include Request
  include Relations
  include Scope
  include Tracing
  include Update

  delegate :_proxy, :_endpoint, :merge_raw!, :select, :becomes, :respond_to?, to: :_data

  def initialize(data = nil, apply_customer_setters = true)
    data ||= DHS::Data.new({}, nil, self.class)
    data = DHS::Data.new(data, nil, self.class) unless data.is_a?(DHS::Data)
    define_singleton_method(:_data) { data }
    apply_custom_setters! if apply_customer_setters
  end

  def as_json(options = nil)
    _data.as_json(options)
  end

  def self.build(data = nil)
    new(data)
  end

  # Override Object#dup because it doesn't support copying any singleton
  # methods, which leads to missing `_data` method when you execute `dup`.
  def dup
    clone
  end

  protected

  def method_missing(name, *args, **keyword_args, &block)
    _data.send(name, *args, **keyword_args, &block)
  end

  def respond_to_missing?(name, include_all = false)
    _data.respond_to_missing?(name, include_all)
  end
end
