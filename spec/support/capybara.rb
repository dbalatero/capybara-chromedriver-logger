require 'selenium-webdriver'
require 'capybara/rspec'

Capybara.register_driver :selenium do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 240

  args = %w[
    disable-default-apps
    disable-extensions
    disable-infobars
    disable-gpu
    disable-popup-blocking
    headless
    no-default-browser-check
    no-first-run
    no-sandbox
    no-proxy-server
    start-fullscreen
    --window-size=1600,1200
  ]

  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
      args: args,
      w3c: false
    },
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
