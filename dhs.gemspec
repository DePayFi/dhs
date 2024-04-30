# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'dhs/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'dhs'
  s.version     = DHS::VERSION
  s.authors     = ['https://github.com/DePayFi/dhs/graphs/contributors']
  s.email       = ['engineering@depay.fi']
  s.homepage    = 'https://github.com/DePayFi/dhs'
  s.summary     = 'REST services accelerator: Rails gem providing an easy, active-record-like interface for http (hypermedia) json services'
  s.description = 'DHS ia a Rails-Gem, providing an ActiveRecord like interface to access HTTP-JSON-Services from Rails Applications. Special features provided by this gem are: Multiple endpoint configuration per resource, active-record-like query-chains, scopes, error handling, relations, request cycle cache, batch processing, including linked resources (hypermedia), data maps (data accessing), nested-resource handling, ActiveModel like backend validation conversion, formbuilder-compatible, three types of pagination support, service configuration per resource, kaminari-support and much more.'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.requirements << 'Ruby >= 2.7.2'
  s.required_ruby_version = '>= 2.7.2'

  s.add_dependency 'activemodel'
  s.add_dependency 'activesupport', '>= 6'
  s.add_dependency 'nio4r', '>= 2.7.1'
  s.add_dependency 'dhc', '>= 2'
  s.add_dependency 'local_uri'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'json', '>=  1.8.2'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rails', '>= 6', '< 7'
  s.add_development_dependency 'rollbar', '<= 2.24.0'
  s.add_development_dependency 'rspec-rails', '>= 3.7.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'sprockets', '< 4'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'webrick'

  s.license = 'GPL-3.0'
end
