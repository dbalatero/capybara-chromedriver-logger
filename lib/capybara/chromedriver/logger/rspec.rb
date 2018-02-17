module Capybara
  module Chromedriver
    module Logger
      class RSpec
        def self.configure!
          ::RSpec.configure do |config|
            filters = { type: :feature, js: true }
            watcher = Capybara::Chromedriver::Logger::Rspec.instance

            config.before :suite, filters do
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
