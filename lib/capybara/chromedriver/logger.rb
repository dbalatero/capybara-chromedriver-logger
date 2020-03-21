require 'capybara'
require 'selenium-webdriver'

require 'capybara/chromedriver/logger/test_hooks'
require 'capybara/chromedriver/logger/version'
require 'capybara/chromedriver/logger/js_error'
require 'capybara/chromedriver/logger/message'
require 'capybara/chromedriver/logger/collector'

module Capybara
  module Chromedriver
    module Logger
      extend self

      def build_capabilities(loggingPrefs: {}, **options)
        options[:chromeOptions] ||= {}

        if options[:chromeOptions][:w3c]
          warn "warning: Setting chromeOptions.w3c to true makes it not "\
            "possible to get console.log messages from Chrome.\n\n"\
            "Please see: https://github.com/SeleniumHQ/selenium/issues/7270"
        else
          options[:chromeOptions][:w3c] = false
        end

        options[:loggingPrefs] = loggingPrefs

        # Support Chrome 75+
        # see: https://github.com/SeleniumHQ/selenium/issues/7342
        options["goog:loggingPrefs"] = loggingPrefs

        ::Selenium::WebDriver::Remote::Capabilities.chrome(options)
      end

      def filters
        @filters || []
      end

      def filters=(filters)
        @filters = filters
      end

      def filter_levels
        @filter_levels || []
      end

      def filter_levels=(filters)
        @filter_levels = filters && filters.map(&:upcase).map(&:to_s)
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
