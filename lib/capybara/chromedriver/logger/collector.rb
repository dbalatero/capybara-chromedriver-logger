module Capybara
  module Chromedriver
    module Logger
      class Collector
        def initialize(log_destination: $stdout, filters: nil)
          @log_destination = log_destination
          @filters = filters || Capybara::Chromedriver::Logger.filters
          @errors = []
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

          raise JsError,
            "Got some JS errors during testing:\n\n#{error_list}"
        end

        def flush_logs!
          browser_logs.each do |log|
            message = Message.new(log)
            errors << message if message.error?

            log_destination.puts message.to_s unless should_filter?(message)
          end
        end

        def clear_errors!
          @errors = []
        end

        def browser_logs
          logs(:browser)
        end

        def logs(type)
          Capybara
            .current_session
            .driver.browser
            .manage
            .logs
            .get(type)
        end

        def should_filter?(message)
          filters.any? { |filter| filter =~ message.message }
        end

        def errors
          @errors
        end

        def filters
          @filters
        end

        def log_destination
          @log_destination
        end
      end
    end
  end
end
