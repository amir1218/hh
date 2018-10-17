class Driver
  def self.load(driver_name:)
    case driver_name
      when 'local_headless'
        Capybara.javascript_driver = :headless_chrome
        Capybara.default_driver = :headless_chrome
        Capybara.register_driver :headless_chrome do |app|
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.read_timeout = 360
          capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
            chromeOptions: { args: %w(headless disable-gpu disable-plugins window-size=1920,1080 no-sandbox disable-dev-shm-usage) }
          )
          Capybara::Selenium::Driver.new app,
                                         browser: :chrome,
                                         http_client: client,
                                         desired_capabilities: capabilities
        end
      else
        Capybara.javascript_driver = :selenium
        Capybara.default_driver = :selenium
        Capybara.register_driver :selenium do |app|
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.read_timeout = 360
          Capybara::Selenium::Driver.new(
            app,
            http_client: client,
            :browser => :chrome
          )
        end
    end
  end
end