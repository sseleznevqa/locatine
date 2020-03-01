require 'spec_helper'

describe 'test' do

  it "fails" do
    # When we are using usual selenium webdriver it will lose element if
    # it has changed attribute that is used for locator.
    driver = Selenium::WebDriver.for :remote, url: "http://localhost:4444/wd/hub", desired_capabilities: :chrome
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='element']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect{driver.find_element(xpath: "//*[@id='element']")}.to raise_error Selenium::WebDriver::Error::NoSuchElementError
    driver.quit
  end

  it "works" do
    # When we are using locatine it is much harder for element to hide.
    caps = Selenium::WebDriver::Remote::Capabilities.chrome('locatine' => {'json' => "#{Dir.pwd}/jsons/elements.json"})
    driver = Selenium::WebDriver.for :remote, url: "http://localhost:7733/wd/hub", desired_capabilities: caps
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='element']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect(driver.find_element(xpath: "//*[@id='element']").text).to eq "Text"
    driver.quit
  end

end
