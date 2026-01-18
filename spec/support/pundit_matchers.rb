# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :policy) do
    require 'pundit/matchers'
  end
end
