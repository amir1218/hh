require 'capybara'
require 'capybara/rspec'
require 'dotenv'
require 'faker'
require 'logger'
require 'pry'
require 'require_all'
require 'rspec'
require 'rspec_html_reporter'
require 'selenium-webdriver'
require 'yaml'

class Logger
  class << self
    def info(message)
      logger.info message unless disabled
    end

    def ap(message, message_type)
      logger.ap message, message_type unless disabled
    end

    def disabled
      @disable ||= false
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end

require_all Pathname.new(File.dirname(__dir__)).join('config/**/*.rb')

Dotenv.overload('.env')
Capybara.app_host = ENV['BASE_URL']
Driver.load(driver_name: 'local')
Capybara.page.driver.browser.manage.window.maximize if Capybara.default_driver == :selenium
RSpec.configure do |config|
  config.include Capybara::DSL
  config.before(:suite) do
    FileUtils.rm_rf(screeshot_dir)
    FileUtils.mkdir_p(screeshot_dir)
  end

  config.after(:each) do |test|
    if test.exception.present?
      take_screenshot(test)
    end
    Capybara.current_session.instance_variable_set(:@touched, false)
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def take_screenshot(example)
  meta              = example.metadata
  filename          = File.basename(meta[:file_path])
  line_number       = meta[:line_number]
  screenshot_name   = "screenshot-#{filename}-#{line_number}.png"
  screenshot_path   = File.join(screeshot_dir, screenshot_name)
  Logger.info screenshot_path
  page.save_screenshot(screenshot_path, full: true)
  Logger.info screenshot_path
end

def screeshot_dir
  Pathname.new(File.dirname(__dir__)).join('reports/screenshots')
end
