require 'capybara'
require 'selenium-webdriver'
require 'selenium/webdriver/remote/http/persistent'

require "capybara/chromedriver/logger/test_hooks"
require "capybara/chromedriver/logger/version"
require "capybara/chromedriver/logger/js_error"
require "capybara/chromedriver/logger/message"
require "capybara/chromedriver/logger/watcher"
require "capybara/chromedriver/logger/selenium_thread_safe_bridge"

class Selenium::WebDriver::Remote::Bridge
  prepend Capybara::Chromedriver::Logger::SeleniumThreadSafeBridge
end

module Capybara
  module Chromedriver
    module Logger
      # This HTTP client is thread-safe, unlike the default client.
      SeleniumHttpClient = ::Selenium::WebDriver::Remote::Http::Persistent

      extend self

      def filters
        @filters || []
      end

      def filters=(filters)
        @filters = filters
      end

      def raise_js_errors?
        !!@raise_js_errors
      end

      def raise_js_errors=(value)
        @raise_js_errors = value
      end
    end
  end
end
