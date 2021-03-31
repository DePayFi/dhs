# frozen_string_literal: true

class DummyRecord < DHS::Record
  endpoint 'http://datastore/v2/records'
  endpoint 'http://datastore/v2/records/{id}'
end
