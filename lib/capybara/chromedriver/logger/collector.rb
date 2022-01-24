module Capybara
  module Chromedriver
    module Logger
      class Collector
        def initialize(options = {})
          @errors = []
          @log_destination = options[:log_destination] || $stdout
          @filters = options[:filters] || Capybara::Chromedriver::Logger.filters
          @filter_levels = options[:filter_levels] ||
            Capybara::Chromedriver::Logger.filter_levels
        end

        def flush_and_check_errors!
          flush_logs!

          raise_errors_if_needed!
          clear_errors!
        end

        private

        def raise_errors_if_needed!
          return unless Capybara::Chromedriver::Logger.raise_js_errors?
          return if errors.empty?

          formatted_errors = errors.map(&:to_s)
          error_list = formatted_errors.join("\n")

          raise JsError, "Got some JS errors during testing:\n\n#{error_list}"
        end

        def flush_logs!
          browser_logs.each do |log|
            message = Message.new(log)

            next if should_filter?(message)

            errors << message if message.error?

            log_destination.puts message.to_s
          end
        end

        def clear_errors!
          @errors = []
        end

        def browser_logs
          logs(:browser)
        end

        def logs(type)
          if Logger.using_selenium_webdriver_4_or_higher?
            Capybara
              .current_session
              .driver.browser
              .logs
              .get(type)
          else
            Capybara
              .current_session
              .driver.browser
              .manage
              .logs
              .get(type)
          end
        end

        def should_filter?(message)
          should_filter_by_level?(message) || should_filter_content?(message)
        end

        def should_filter_by_level?(message)
          filter_levels.include?(message.level)
        end

        def should_filter_content?(message)
          filters.any? { |filter| filter =~ message.message }
        end

        attr_reader :errors
        attr_reader :filters
        attr_reader :filter_levels
        attr_reader :log_destination
      end
    end
  end
end
