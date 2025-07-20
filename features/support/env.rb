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

Capybara.register_driver :selenium_chrome_headless do |app|
  chrome_opts = ::Selenium::WebDriver::Chrome::Options.new
  chrome_opts.add_argument('--headless')
  chrome_opts.add_argument('--disable-gpu')
  chrome_opts.add_argument('--window-size=1400,1400')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_opts)
rescue Webdrivers::BrowserNotFoundError
  warn "[capybara] Chrome binary not found—skipping :selenium_chrome_headless"
  nil
end

Capybara.register_driver :selenium_firefox_headless do |app|
  firefox_opts = ::Selenium::WebDriver::Firefox::Options.new
  firefox_opts.add_argument('-headless')
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: firefox_opts)
rescue Webdrivers::BrowserNotFoundError
  warn "[capybara] Firefox binary not found—skipping :selenium_firefox_headless"
  nil
end

chosen = ENV.fetch('BROWSER', 'firefox').downcase
js_driver = case chosen
            when 'chrome'  then :selenium_chrome_headless
            when 'firefox' then :selenium_firefox_headless
            else
              warn "[capybara] Unknown BROWSER=#{chosen}, defaulting to firefox"
              :selenium_firefox_headless
            end

unless Capybara.drivers.key?(js_driver)
  fallback = Capybara.drivers.key?(:selenium_firefox_headless) ? :selenium_firefox_headless : :rack_test
  warn "[capybara] Falling back to #{fallback.inspect}"
  js_driver = fallback
end

Capybara.default_driver    = :rack_test
Capybara.javascript_driver = js_driver

ActionController::Base.allow_rescue = false