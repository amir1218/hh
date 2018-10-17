class DOM
  def initialize
    @log_space_name = 'DOM'
  end

  def wait_until(&blk)
    timer = 0
    @default_wait_time = 60 if @default_wait_time.nil?
    begin
      until yield || timer > @default_wait_time do
        sleep(1)
        timer += 1
      end
      unless yield
        raise Capybara::ExpectationNotMet, "Expected #{blk.to_raw_source(strip_enclosure: true)} to be true but it returned false after allowed wait time."
      end
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      log('Skipping wait_until. Expected element is not on the page any more.')
    end
  end

  def wait_while(&blk)
    timer = 0
    @default_wait_time = 60 if @default_wait_time.nil?
    begin
      while yield && timer < @default_wait_time do
        sleep(1)
        timer += 1
      end
      if yield
        raise Capybara::ExpectationNotMet, "Expected #{blk.to_raw_source(strip_enclosure: true)} to be false but it returned true after allowed wait time."
      end
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      log('Skipping wait_while. Expected element is not on the page any more.')
    end
  end

  def log(data)
    Logger.info "#{@log_space_name}::#{data}"
  end
end