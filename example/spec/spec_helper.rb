require 'webdrivers'
require "selenium-webdriver"

def page(number)
  "file://#{Dir.pwd}/spec/test_pages/page#{number}.html"
end
