require "pry"
require "bundler/setup"
require "webdrivers/chromedriver"
require "capybara/chromedriver/logger"

Dir.glob("spec/support/**/*.rb") { |f| require_relative "../#{f}" }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
