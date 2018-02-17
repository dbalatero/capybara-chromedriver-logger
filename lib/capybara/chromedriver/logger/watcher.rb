require 'thread'

module Capybara
  module Chromedriver
    module Logger
      class Watcher
        def initialize(log_destination: $stdout, filters: nil)
          @log_destination = log_destination
          @last_timestamp = 0
          @mutex = Mutex.new
          @thread = nil
          @paused = true
          @filters = filters || Capybara::Chromedriver::Logger.filters
          @errors = []
        end

        def before_example!
          unpause!
          start_listener!
        end

        def after_example!
          pause!
          flush_logs!

          raise_errors_if_needed!
          clear_errors!
        ensure
          thread.kill if thread
        end

        private

        def start_listener!
          @thread = Thread.new do
            loop do
              flush_logs! unless paused?
              sleep 0.1
            end
          end
        end

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
            next if log.timestamp < last_timestamp

            @last_timestamp = log.timestamp

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
          mutex.synchronize do
            Capybara
              .current_session
              .driver.browser
              .manage
              .logs
              .get(type)
          end
        end

        def should_filter?(message)
          filters.any? { |filter| filter =~ message.message }
        end

        def errors
          @errors
        end

        def unpause!
          @paused = false
        end

        def pause!
          @paused = true
        end

        def mutex
          @mutex
        end

        def filters
          @filters
        end

        def last_timestamp
          @last_timestamp
        end

        def paused?
          !!@paused
        end

        def log_destination
          @log_destination
        end

        def thread
          @thread
        end
      end
    end
  end
end
