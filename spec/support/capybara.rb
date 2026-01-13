# frozen_string_literal: true

Capybara.register_driver :selenium_chromium_headless do |_|
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = '/Applications/Chromium.app/Contents/MacOS/Chromium'
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')

  Capybara.register_driver :selenium_chromium_headless do |app|
    Selenium::WebDriver::Chrome.driver_path = '/opt/homebrew/bin/chromedriver'

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end

Capybara.javascript_driver = :selenium_chromium_headless

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chromium_headless
  end
end
