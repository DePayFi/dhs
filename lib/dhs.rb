# frozen_string_literal: true

require 'dhc'

module DHS
  autoload :Configuration, 'dhs/concerns/configuration'
  autoload :AutoloadRecords, 'dhs/concerns/autoload_records'
  autoload :Collection, 'dhs/collection'
  autoload :Complex, 'dhs/complex'
  autoload :Config, 'dhs/config'
  autoload :Data, 'dhs/data'
  autoload :ExtendedRollbar, 'dhs/interceptors/extended_rollbar/interceptor'
  autoload :Endpoint, 'dhs/endpoint'
  autoload :Inspect, 'dhs/concerns/inspect'
  module Interceptors
    module AutoOauth
      autoload :ThreadRegistry, 'dhs/interceptors/auto_oauth/thread_registry'
      autoload :Interceptor, 'dhs/interceptors/auto_oauth/interceptor'
    end

    module RequestCycleCache
      autoload :ThreadRegistry, 'dhs/interceptors/request_cycle_cache/thread_registry'
      autoload :Interceptor, 'dhs/interceptors/request_cycle_cache/interceptor'
    end

    module ExtendedRollbar
      autoload :ThreadRegistry, 'dhs/interceptors/extended_rollbar/thread_registry'
      autoload :Interceptor, 'dhs/interceptors/extended_rollbar/interceptor'
      autoload :Handler, 'dhs/interceptors/extended_rollbar/handler'
    end
  end
  autoload :IsHref, 'dhs/concerns/is_href'
  autoload :Item, 'dhs/item'
  autoload :OAuth, 'dhs/concerns/o_auth.rb'
  autoload :OptionBlocks, 'dhs/concerns/option_blocks'
  autoload :Pagination, 'dhs/pagination/base'
  module Pagination
    autoload :Offset, 'dhs/pagination/offset'
    autoload :Page, 'dhs/pagination/page'
    autoload :TotalPages, 'dhs/pagination/total_pages'
    autoload :OffsetPage, 'dhs/pagination/offset_page'
    autoload :NextOffset, 'dhs/pagination/next_offset'
    autoload :NextParameter, 'dhs/pagination/next_parameter'
    autoload :Start, 'dhs/pagination/start'
    autoload :Link, 'dhs/pagination/link'
  end
  autoload :Problems, 'dhs/problems/base'
  module Problems
    autoload :Base, 'dhs/problems/base'
    autoload :Errors, 'dhs/problems/errors'
    autoload :Nested, 'dhs/problems/nested/base'
    module Nested
      autoload :Base, 'dhs/problems/nested/base'
      autoload :Errors, 'dhs/problems/nested/errors'
      autoload :Warnings, 'dhs/problems/nested/warnings'
    end
    autoload :Warnings, 'dhs/problems/warnings'
  end
  autoload :Proxy, 'dhs/proxy'
  autoload :Record, 'dhs/record'
  autoload :Unprocessable, 'dhs/unprocessable'

  include Configuration
  include OptionBlocks

  require 'dhs/record' # as dhs records in an application are directly inheriting it

  if defined?(Rails)
    include AutoloadRecords
    require 'dhs/railtie'
  end
end
