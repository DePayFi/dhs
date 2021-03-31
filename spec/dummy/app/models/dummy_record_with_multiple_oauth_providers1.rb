# frozen_string_literal: true

class DummyRecordWithMultipleOauthProviders1 < DHS::Record
  oauth(:provider1)
  endpoint 'http://datastore/v2/records_with_multiple_oauth_providers_1'
  endpoint 'http://datastore/v2/records_with_multiple_oauth_providers_1/{id}'
end
