# frozen_string_literal: true

# An endpoint is used as source to fetch objects
class DHS::Endpoint

  def self.for_url(url)
    template, record = DHS::Record::Endpoints.all.dup.detect do |template, _record|
      DHC::Endpoint.match?(url, template)
    end
    record&.endpoints&.detect { |endpoint| endpoint.url == template }
  end
end
