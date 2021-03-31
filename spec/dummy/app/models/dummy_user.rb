# frozen_string_literal: true

class DummyUser < DHS::Record
  endpoint 'http://datastore/v2/users'
  endpoint 'http://datastore/v2/users/{id}'
end
