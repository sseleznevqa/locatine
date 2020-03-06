require 'spec_helper'
require 'json'

def make_driver
  caps = Selenium::WebDriver::Remote::Capabilities.chrome('locatine' => {'json' => "#{Dir.pwd}/jsons/elements.json"})
  Selenium::WebDriver.for :remote, url: "http://localhost:7733/wd/hub", desired_capabilities: caps
end

describe 'examples to see the powers of locatine' do

  after(:each) do
    FileUtils.remove_dir("#{Dir.pwd}/jsons/", true)
  end

  it "fails to find the lost element without locatine" do
    # When we are using usual selenium webdriver it will lose element if
    # it has changed attribute that is used for locator.
    driver = Selenium::WebDriver.for :remote,
           url: "http://localhost:4444/wd/hub", desired_capabilities: :chrome
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='good']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect{driver.find_element(xpath: "//*[@id='good']")}.
                  to raise_error Selenium::WebDriver::Error::NoSuchElementError
    driver.quit
  end

  it "finds the lost element with locatine" do
    # When we are using locatine it is much harder for element to hide.
    caps = Selenium::WebDriver::Remote::Capabilities.chrome('locatine' => {'json' => "#{Dir.pwd}/jsons/elements.json"})
    driver = Selenium::WebDriver.for :remote, url: "http://localhost:7733/wd/hub", desired_capabilities: caps
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='good']kjhgkjhg")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect(driver.find_element(xpath: "//*[@id='good']").text).to eq "Text"
    driver.quit
  end

  it "loosing element without name" do
    driver = make_driver # Launch shortcut see begining of the file.
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='good']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect{driver.find_element(css: "#good")}.
                  to raise_error Selenium::WebDriver::Error::NoSuchElementError
    driver.quit
  end

  it "remebers element by name. And finds it" do
    driver = make_driver
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='good']['main element']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect(driver.find_element(css: "#good/*main element*/").text).to eq "Text"
    driver.quit
  end

  it "even can use something rememebered without locators" do
    driver = make_driver
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='good']['main element']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect(driver.find_element(css: "/*main element*/").text).to eq "Text"
    driver.quit
  end

  it "can be strict sometimes" do
    driver = make_driver
    driver.navigate.to page 1
    element = driver.find_element(xpath: "//*[@id='good']['main element']")
    expect(driver.find_element(css: "/*exactly main element*/").text).to eq "Text"
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect{driver.find_element(css: "/*exactly main element*/")}.
                  to raise_error Selenium::WebDriver::Error::NoSuchElementError
    driver.quit
  end

  it "can find element without classic locator at all" do
    driver = make_driver
    driver.navigate.to page 1
    # good div will be found since element has uniq attribute id = good
    # and its a div
    # <div id="good" class ="1 2 3 4 5">Text</div>
    element = driver.find_element(xpath: "['good div']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    # Since element is remembered id changing is not a blocker to find element
    expect(driver.find_element(css: "/*good div*/").text).to eq "Text"
    driver.quit
  end

  it "can be configured" do
    json = { name: 'element to find', # Name to use
             untrusted: ['id'], # Do not use id if element was lost
             timeout: 10, # Look for lost element for 10 seconds only
             # and a custom locator to use.
             locator: {using: "css selector", value: "#good"}
           }.to_json
    driver = make_driver
    driver.navigate.to page 1
    element = driver.find_element(xpath: "['#{json}']")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect(driver.find_element(css: "/*#{json}*/").text).to eq "Text"
    # Note! You can configure locatine to use some settings for all searches
    # by default. See line 5. You can add there any settings.
    driver.quit
  end

  it "finally" do
    # See spec_helper lines 29-35 to see how locatine locator is added to
    # selenium-webdriver
    driver = make_driver
    driver.navigate.to page 1
    element = driver.find_element(locatine: "good div")
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect(driver.find_element(locatine: "good div").text).to eq "Text"
    driver.quit
  end

  it "by the way collections can be found too" do
    # Elements are
    # <div id="collection" class="a b c d e" value="one">One</div>
    # <div id="collection" class="a b c d e" value="two">2</div>
    driver = make_driver
    driver.navigate.to page 1
    collection = driver.find_elements(locatine: "collection div")
    expect(collection.length).to eq 2
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", collection[0])
    # <div id="lost" class="a b c d e" value="one">One</div>
    # <div id="collection" class="a b c d e" value="two">2</div>
    expect(driver.find_elements(locatine: "collection div")[0].text).to eq "2"
    driver.execute_script("arguments[0].setAttribute('id', 'lost')", collection[1])
    # <div id="lost" class="a b c d e" value="one">One</div>
    # <div id="lost" class="a b c d e" value="two">2</div>
    expect(driver.find_elements(locatine: "collection div")[0].text).to eq "One"
    expect(driver.find_elements(locatine: "collection div").length).to eq 2
    driver.quit
  end



end
