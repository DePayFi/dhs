# frozen_string_literal: true

module Providers
  class CustomerSystem < DHS::Record
    provider(headers: { 'Authorization': 'token123' })
  end
end
