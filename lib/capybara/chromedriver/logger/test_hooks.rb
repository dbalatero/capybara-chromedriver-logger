module Capybara
  module Chromedriver
    module Logger
      class TestHooks
        def self.for_rspec!
          ::RSpec.configure do |config|
            filters = { type: :feature }

            config.before :each, filters do
              @_log_watcher = Capybara::Chromedriver::Logger::Watcher.new
              @_log_watcher.before_example!
            end

            config.after :each, filters do
              @_log_watcher.after_example!
            end
          end
        end
      end
    end
  end
end
