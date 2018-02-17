# capybara-chromedriver-logger

This gem provides real-time `console.log` debug output for Ruby feature specs running under Chromedriver.

We currently assume you're running:

* capybara
* chromedriver
* rspec
* selenium-webdriver

to handle your JS feature specs. I'd love to expand support for other combinations of test environments!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capybara-chromedriver-logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-chromedriver-logger

## Usage

You'll want to modify your `spec_helper.rb` file to configure Capybara correctly:

```ruby
Capybara.register_driver(:chrome) do |app|
  # Turn on browser logs
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    loggingPrefs: {
      browser: 'ALL'
    }
  )

  # Selenium needs to use a thread-safe HTTP client
  client = Capybara::Chromedriver::Logger::SeleniumHttpClient.new

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities,
    http_client: client
  )
end

# Use the driver we've configured
Capybara.default_driver = :chrome
Capybara.javascript_driver = :chrome

# Setup before/after hooks for your feature specs
Capybara::Chromedriver::Logger::TestHooks.for_rspec!
```

## Configuration

Here are examples of the supported configuration options:

```ruby
# If you set this to true, any specs that generate console errors
# will automatically raise. This is similar to poltergeist's
# `js_errors: true` config option
#
# If you filter out any errors with the `filters` option, they will
# not trigger an exception in your spec examples.
#
# default: false
Capybara::Chromedriver::Logger.raise_js_errors = true

# If third-party libraries are dumping obnoxious logs into your output,
# you can filter them out here.
#
# default: []
Capybara::Chromedriver::Logger.filters = [
  /Download the React DevTools/i,
  /The SSL certificate used to load resources from/i
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dbalatero/capybara-chromedriver-logger.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
