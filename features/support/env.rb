def find_available_browser
  return 'chrome' if system('which google-chrome > /dev/null')
  return 'chromium' if system('which chromium > /dev/null')
  return 'firefox' if system('which firefox > /dev/null')
  nil
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __dir__)

require 'simplecov'
SimpleCov.start do
  add_filter 'features/support/hooks.rb'
end

require 'cucumber/rails'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'webdrivers'

require 'database_cleaner/active_record'

Capybara.default_max_wait_time = 60

available_browser = find_available_browser
puts "== Detected browser: #{available_browser || 'none'}"

# Register Chrome/Chromium
Capybara.register_driver :selenium_chrome_headless do |app|
  chrome_opts = Selenium::WebDriver::Chrome::Options.new
  chrome_opts.add_argument('--headless')
  chrome_opts.add_argument('--disable-gpu')
  chrome_opts.add_argument('--no-sandbox')
  chrome_opts.add_argument('--window-size=1400,1400')

  # Specify binary if needed
  if available_browser == 'chromium'
    chrome_opts.binary = '/usr/bin/chromium'
  elsif available_browser == 'chrome'
    chrome_opts.binary = '/usr/bin/google-chrome'
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_opts)
end

# Register Firefox
Capybara.register_driver :selenium_firefox_headless do |app|
  firefox_opts = Selenium::WebDriver::Firefox::Options.new
  firefox_opts.add_argument('-headless')
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: firefox_opts)
end

# Pick JS driver based on detection
driver_map = {
  'chrome'   => :selenium_chrome_headless,
  'chromium' => :selenium_chrome_headless,
  'firefox'  => :selenium_firefox_headless
}

js_driver = driver_map.fetch(available_browser) do
  warn "[capybara] Nenhum navegador disponível detectado. Usando :rack_test."
  :rack_test
end

unless Capybara.drivers.key?(js_driver)
  warn "[capybara] Driver #{js_driver.inspect} não está registrado. Fallback para :rack_test"
  js_driver = :rack_test
end

Capybara.default_driver    = :rack_test
Capybara.javascript_driver = js_driver

puts "== Capybara.default_driver:    #{Capybara.default_driver}"
puts "== Capybara.javascript_driver: #{Capybara.javascript_driver}"

ActionController::Base.allow_rescue = false