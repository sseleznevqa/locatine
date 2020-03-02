require 'webdrivers'
require 'selenium-webdriver'
require 'json'

SELENIUM = "http://localhost:7733/wd/hub"

RSpec.configure do |config|
  config.add_setting :browser
  config.after(:all) do
    close_browser(config)
    # Clearing stored data
    # Delete the line below if you wanna use this code
    # like a base for your locatine framework
    FileUtils.rm_rf("#{Dir.pwd}/jsons/.", secure: true)
  end
end

def close_browser(config)
  if config.browser != nil
    config.browser.quit
    config.browser = nil
  end
end

def page(number)
  "file://#{Dir.pwd}/spec/test_pages/page#{number}.html"
end

# Invading selenium
finders = {}
Selenium::WebDriver::SearchContext::FINDERS.each_pair do |key, value|
  finders[key] = value
end
finders[:locatine] = 'locatine'
Selenium::WebDriver::SearchContext::FINDERS = finders.freeze

def find(data: '', locator: nil)
  magic_comment = data.class == Hash ? data.to_json : data
  return browser.find_element(locatine: magic_comment) unless locator

  locator[:css] = locator[:css] + "/*#{magic_comment}*/" if locator[:css]
  locator[:xpath] = locator[:xpath] + "['#{magic_comment}']" if locator[:xpath]

  return browser.find_element(locator)
end

def collect(data: '', locator: nil)
  magic_comment = data.class == Hash ? data.to_json : data
  return browser.find_elements(locatine: magic_comment) unless locator

  locator[:css] = locator[:css] + "/*#{magic_comment}*/" if locator[:css]
  locator[:xpath] = locator[:xpath] + "['#{magic_comment}']" if locator[:xpath]

  return browser.find_elements(locator)
end

def browser
  RSpec.configuration.browser ||= Selenium::WebDriver.
                                            for :remote,
                                                url: SELENIUM,
                                                desired_capabilities: the_caps
  RSpec.configuration.browser
end

def the_caps
  Selenium::WebDriver::Remote::Capabilities.
            chrome('locatine' => {'json' => file_path})
end

def file_path
  name = RSpec.current_example.metadata[:example_group][:full_description]
  "#{Dir.pwd}/jsons/#{name}.json"
end
