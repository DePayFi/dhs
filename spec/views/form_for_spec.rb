# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

describe 'form_for helper' do
  before do
    class Feedback < DHS::Record
      endpoint '{+datastore}/v2/feedbacks'
    end
    assign(:instance, Feedback.new)
  end

  it 'supported by DHS' do
    render template: 'form_for.html'
    expect(rendered).to have_selector('form')
    expect(rendered).to have_selector('input[name="feedback[name]"]')
    expect(rendered).to have_selector('textarea[name="feedback[text]"]')
  end
end
