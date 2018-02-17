RSpec.describe "watcher", with_server: true, js: true, type: :feature do
  let(:log_destination) do
    StringIO.new
  end

  let(:logger) do
    Capybara::Chromedriver::Logger::Watcher.new(log_destination: log_destination)
  end

  before do
    Capybara::Chromedriver::Logger.raise_js_errors = false
    logger.before_example!
  end

  it "receiving no errors" do
    visit "/none"

    expect_to_have_inserted_element
    logger.after_example!
    expect_no_log_messages
  end

  it "receiving console errors without error raising" do
    visit "/severe"

    expect_to_have_inserted_element
    expect { logger.after_example! }.to_not raise_error
    expect_log_message("A console error")
  end

  it "receiving console errors with error raising" do
    Capybara::Chromedriver::Logger.raise_js_errors = true

    visit "/severe"

    expect_to_have_inserted_element
    expect { logger.after_example! }
      .to raise_error(Capybara::Chromedriver::Logger::JsError, /A console error/)
    expect_log_message("A console error")
  end

  it "receiving logs with linebreaks" do
    visit "/multiline"

    expect_to_have_inserted_element
    logger.after_example!

    expect_log_message("Some log\n         in somefile.jsx\n         in anotherfile.jsx")
  end

  it "receiving console info logs" do
    visit "/info"

    expect_to_have_inserted_element
    logger.after_example!
    expect_log_message("A console log")
  end

  def expect_no_log_messages
    expect(log_destination.string).to eq('')
  end

  def expect_log_message(message)
    expect(log_destination.string).to include(message)
  end
end
