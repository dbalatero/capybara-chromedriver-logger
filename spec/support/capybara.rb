require 'selenium-webdriver'
require 'capybara/rspec'

Capybara.register_driver :selenium do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 240

  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    loggingPrefs: {
      browser: 'ALL'
    }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities,
    http_client: client
  )
end

Capybara.default_driver = :selenium

RSpec.configure do |config|
  config.include Capybara::DSL
end
