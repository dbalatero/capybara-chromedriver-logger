module Capybara
  module Chromedriver
    module Logger
      # Ensure our polling thread doesn't compete with the main spec example
      module SeleniumThreadSafeBridge
        def __execute_lock
          @__execute_lock ||= Mutex.new
        end

        def execute(*args)
          __execute_lock.synchronize { super }
        end
      end
    end
  end
end
