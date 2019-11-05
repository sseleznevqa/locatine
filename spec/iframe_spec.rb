require 'spec_helper'
describe 'Crazy Iframe' do
  before(:all) do
    @path19 = "file://#{Dir.pwd}/spec/test_data/test-19.html"
    @dir = './Locatine_files/'
    @file = './Locatine_files/default.json'
    Watir.default_timeout = 3
  end
  before(:each) do
    @s = Locatine::Search.new
  end

  it "finding deep nested element (simply)" do
    @s.browser.quit
    @s.browser = Watir::Browser.new
    @s.learn = true
    @s.browser.goto @path19
    initial_label = @s.find("initial label")
    i1 = @s.find("second iframe")
    i2 = @s.find({name: "third iframe", iframe: i1})
    label = @s.find({name: "finally label", iframe: i2})
    @s.learn = false
    expect(@s.find({name: "finally label", iframe: i2}).text).to be == "Gotcha!"
    expect(@s.find("initial label").text).to be == "Rock-n-roll"
  end

  after(:all) do
    File.delete(@file) if File.exist?(@file)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
  end
  after(:each) do
    @s.browser.quit
  end
end
