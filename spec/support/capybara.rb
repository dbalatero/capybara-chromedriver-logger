require 'selenium-webdriver'
require 'capybara/rspec'

Capybara.register_driver :selenium do |app|
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

  capabilities = Capybara::Chromedriver::Logger.build_capabilities(
    args: args
  )

  if ENV["VERBOSE_SELENIUM_WEBDRIVER"] == "1"
    capabilities.add_argument "--verbose"
    Selenium::WebDriver.logger.level = :debug
  end

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: capabilities,
    timeout: 240
  )
end

Capybara.default_driver = :selenium

RSpec.configure do |config|
  config.include Capybara::DSL
end
