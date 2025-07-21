# features/support/env.rb

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __dir__)

require 'simplecov'
SimpleCov.start

require 'cucumber/rails'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'webdrivers'

require 'database_cleaner/active_record'

Capybara.default_max_wait_time = 5

Capybara.register_driver :selenium_chrome_headless do |app|
  chrome_opts = Selenium::WebDriver::Chrome::Options.new
  chrome_opts.add_argument('--headless')
  chrome_opts.add_argument('--disable-gpu')
  chrome_opts.add_argument('--window-size=1400,1400')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_opts)
end

Capybara.register_driver :selenium_firefox_headless do |app|
  firefox_opts = Selenium::WebDriver::Firefox::Options.new
  firefox_opts.add_argument('-headless')
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: firefox_opts)
end

browser = ENV.fetch('BROWSER', 'firefox').downcase
driver_map = {
  'chrome'  => :selenium_chrome_headless,
  'firefox' => :selenium_firefox_headless
}

js_driver = driver_map.fetch(browser) do
  warn "[capybara] BROWSER=#{browser.inspect} não reconhecido. Usando :selenium_firefox_headless"
  :selenium_firefox_headless
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