require 'spec_helper'
describe 'E2E basic user story' do
  before(:all) do
    @path1 = "file://#{Dir.pwd}/spec/test_data/test-1.html"
    @path2 = "file://#{Dir.pwd}/spec/test_data/test-2.html"
    @path3 = "file://#{Dir.pwd}/spec/test_data/test-3.html"
    @path4 = "file://#{Dir.pwd}/spec/test_data/test-4.html"
    @path5 = "file://#{Dir.pwd}/spec/test_data/test-5.html"
    @dir = './Locatine_files/'
    @file = './Locatine_files/default.json'
    Watir.default_timeout = 3
  end
  before(:each) do
    @s = Locatine::Search.new
  end
  it "Defining elements" do
    @s.browser.quit
    @s = Locatine::Search.new learn: true, browser: Watir::Browser.new
    @s.browser.goto @path1
    expect(@s.collect(name: "lis").length).to be == 3
    expect(@s.find(name: "element").text).to be == "Element"
    # Guess test
    expect(@s.find(name: "important span", vars: {"tag":"span", "text":"kadabra", "var":"che"}).text).to be == "Abrakadabra"
    expect(@s.find(name: "span for guess").text).to be == "for guess"
    iframe = @s.find(name: "iframe")
    expect(@s.find(name: "h3 banana", iframe: iframe).text).to be == "Banana"
    expect(@s.find("h4 css").text).to be == "h4 css"
    expect(@s.find("by coordinates").present?).to be == true
  end
  it "Finding elements" do
    @s.browser.goto @path2
    expect(@s.collect(name: "lis").length).to be == 3
    expect(@s.find(name: "element").text).to be == "Element"
    iframe = @s.find(name: "iframe")
    expect(@s.find(name: "h3 banana", iframe: iframe).text).to be == "Banana"
  end
  it "Finding elelements with dynamic vars" do
    # Guess test
    @s.browser.goto @path2
    Watir.default_timeout = 30
    start = Time.now
    expect(@s.find(name: "important span", vars: {"tag":"spoon", "text":"kedavra", "var":"ba"}).text).to be == "Abrakedavra"
    Watir.default_timeout = 3
    expect(Time.now-start).to be < 10
  end
  it "can return a locator" do
    @s.browser.goto @path2
    expect(@s.browser.elements(@s.lctr(name: "lis")).length).to be == 3
    expect(@s.browser.element(@s.lctr(name: "element")).text).to be == "Element"
    # Guess test
    expect(@s.browser.element(@s.lctr(name: "important span", vars: {"tag":"spoon", "text":"kedavra", "var":"ba"})).text).to be == "Abrakedavra"
  end
  it "Ignores exact if element still unstable" do
    @s.browser.goto @path2
    expect(@s.find(name: "span for guess", exact: true).text).to be == "for guess"
  end
  it "Finding exacts" do
    @s.browser.goto @path2
    expect(@s.collect(name: "lis", exact: true).length).to be == 3
    expect(@s.find(name: "element", exact: true).text).to be == "Element"
  end
  it "Fails on exact when elements are lost" do
    @s.browser.goto @path3
    expect(@s.collect(name: "lis", exact: true)).to be == nil
    expect(@s.find(name: "element", exact: true)).to be == nil
    expect(@s.find(name: "span for guess", exact: true)).to be == nil
  end
  it "Fails when elements are lost and there is nothing similar" do
    @s.browser.goto @path4
    expect{@s.collect(name: "lis")}.to raise_error(RuntimeError, 'Unable to find element lis in Default')
    binding.pry
    expect{@s.find(name: "element")}.to raise_error(RuntimeError, 'Unable to find element similar to element in Default')
  end
  it "Finding lost elements" do
    @s.browser.goto @path3
    expect(@s.collect(name: "lis").length).to be == 3
    expect(@s.find(name: "element").text).to be == "Element"
    expect(@s.find("h4 css").text).to be == "found anyway"
    expect(@s.find("by coordinates").text).to be == "O"
  end
  it "Ignoring unstable attributes" do
    Watir.default_timeout = 15
    start = Time.now
    @s.browser.goto @path2
    expect(@s.collect(name: "lis").length).to be == 3
    expect(@s.find(name: "element").text).to be == "Element"
    expect(Time.now-start).to be < 10
  end
  it "Finds element if nesting structure is broken" do
    Watir.default_timeout = 3
    @s.browser.goto @path5
    expect(@s.collect(name: "lis").length).to be == 3
    expect(@s.find(name: "element").text).to be == "Element"
  end
  after(:all) do
    File.delete(@file) if File.exist?(@file)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
  end
  after(:each) do
    @s.browser.quit
  end
end
