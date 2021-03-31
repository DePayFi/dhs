# frozen_string_literal: true

require 'dhc'
class DHC::Config

  def _cleanup
    @endpoints = {}
    @placeholders = {}
    @interceptors = nil
  end
end

class DHS::Record

  DESCENDANTS = []

  def self.inherited(child)
    DESCENDANTS.push(child)
    child.singleton_class.class_eval do
      define_method(:inherited) do |grand_child|
        DESCENDANTS.push(grand_child)
      end
    end
    super
  end

end

def reset_dhc
  DHC::Config.instance._cleanup
end

def reset_dhs
  DHS::Record::Endpoints.all = {}
  DHS::Record::DESCENDANTS.each do |decendant|
    decendant.endpoints = [] if !decendant.name['DHS'] && defined?(decendant.endpoints)
    decendant.configuration({}) if !decendant.name['DHS']
  end
end

def model_files_to_reload
  Dir.glob(Rails.root.join('app', 'models', '**', '*.rb'))
end

def reload_direct_inheritance
  model_files_to_reload.map do |file|
    next unless File.read(file).match('DHS::Record')
    load file
    file.split('models/').last.gsub('.rb', '').classify
  end.compact
end

def reload_inheriting_records(parents)
  model_files_to_reload.each do |file|
    next if parents.none? { |parent| File.read(file).match(parent) }
    load file
  end
end

RSpec.configure do |config|
  config.before do |spec|
    reset_dhc unless spec.metadata.key?(:reset_before) && spec.metadata[:reset_before] == false
    reset_dhs unless spec.metadata.key?(:reset_before) && spec.metadata[:reset_before] == false
    next if !spec.metadata.key?(:dummy_models) || spec.metadata[:dummy_models] != true
    reload_inheriting_records(reload_direct_inheritance)
  end
end
