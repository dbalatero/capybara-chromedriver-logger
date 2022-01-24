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

      # == compatibility with selenium-webdriver 4.x
      #
      # Selenium::WebDriver's API changed significantly between 3.x and 4.x.
      #
      # This method delegates to build_capabilities_3 or build_capabilities_4.
      def build_capabilities(logging_prefs: { browser: 'ALL' }, **options)
        # backwards compatibility with camelcase
        logging_prefs = options.delete(:loggingPrefs) || logging_prefs

        if using_selenium_webdriver_4_or_higher?
          # is there a better way to detect Selenium::WebDriver compatibility?
          build_capabilities_4(logging_prefs: logging_prefs, **options)
        else
          build_capabilities_3(loggingPrefs: logging_prefs, **options)
        end
      end

      # For selenium-webdriver >= 4.0.  Capabilities will be created using
      # Selenium::WebDriver::Options.chrome and should be passed to
      # Capybara::Selenium::Driver.new(..., capabilities: capabilities)
      def build_capabilities_4(logging_prefs: { browser: 'ALL' }, **options)
        ::Selenium::WebDriver::Options.chrome(**options,
                                            logging_prefs: logging_prefs)
      end

      # For selenium-webdriver < 4.0.  Capabilities will be created using
      # Selenium::WebDriver::Remote::Capabilities.chrome and should be passed to
      # Capybara::Selenium::Driver.new(..., desired_capabilities: capabilities)
      def build_capabilities_3(loggingPrefs: { browser: 'ALL' }, **options)
        options[:chromeOptions] ||= {}

        if options[:chromeOptions][:w3c]
          warn "warning: Setting chromeOptions.w3c to true makes it not "\
            "possible to get console.log messages from Chrome.\n\n"\
            "Please see: https://github.com/SeleniumHQ/selenium/issues/7270"
        else
          options[:chromeOptions][:w3c] = false
        end

        if loggingPrefs[:browser] != 'ALL'
          warn "warning: loggingPrefs needs to contain { browser: 'ALL' } "\
            "when using Logger#build_capabilities"
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

      # always returns true if Gem::Version isn't defined
      def using_selenium_webdriver_4_or_higher?
        return true unless defined?(Gem::Version)
        return false unless defined?(::Selenium::WebDriver::VERSION)
        Gem::Version.new(::Selenium::WebDriver::VERSION) >=
          Gem::Version.new("4.0.0.0.a")
      end

    end
  end
end
