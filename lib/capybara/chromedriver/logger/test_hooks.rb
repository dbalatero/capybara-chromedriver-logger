module Capybara
  module Chromedriver
    module Logger
      class TestHooks
        def self.for_rspec!
          ::RSpec.configure do |config|
            filters = { type: :feature }
            watcher = Capybara::Chromedriver::Logger::Watcher.instance

            config.before :suite do
              watcher.before_suite!
            end

            config.before :each, filters do
              watcher.before_example!
            end

            config.after :each, filters do
              watcher.after_example!
            end
          end
        end
      end
    end
  end
end
