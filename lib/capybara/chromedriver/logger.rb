require 'capybara'
require 'selenium-webdriver'

require "capybara/chromedriver/logger/test_hooks"
require "capybara/chromedriver/logger/version"
require "capybara/chromedriver/logger/js_error"
require "capybara/chromedriver/logger/message"
require "capybara/chromedriver/logger/collector"

module Capybara
  module Chromedriver
    module Logger
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
