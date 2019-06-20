require 'spec_helper'
require 'net/http'
require 'json'

describe 'Autolearn' do
  before(:all) do
    @path16 = "file://#{Dir.pwd}/spec/test_data/test-16.html"
    @path17 = "file://#{Dir.pwd}/spec/test_data/test-17.html"
    @path18 = "file://#{Dir.pwd}/spec/test_data/test-18.html"
    @dir = './Locatine_files/'
    @path = './Locatine_files/default.json'
    Watir.default_timeout = 3
  end

  before(:each) do
    @s = Locatine::Search.new
  end

  it 'No autolearn when false' do
    @s.browser.quit
    @s.browser = Watir::Browser.new
    @s.autolearn = false
    @s.learn = true
    @s.browser.goto @path16
    @s.find("test element")
    @s.learn = false
    @s.browser.goto @path17
    @s.find("test element")
    file = File.read(@path)
    expect(file.include?("Bye")).to be false
  end

  it 'Autolearn when true' do
    @s.browser.quit
    @s.browser = Watir::Browser.new
    @s.autolearn = true
    @s.learn = true
    @s.browser.goto @path16
    @s.find("best element")
    @s.learn = false
    @s.browser.goto @path17
    @s.find("best element")
    file = File.read(@path)
    expect(file.include?("Bye")).to be true
  end

  it 'Autolearn turns on when none' do
    @s.browser.quit
    @s.browser = Watir::Browser.new
    @s.learn = true
    @s.browser.goto @path16
    @s.find("jest element")
    @s.learn = false
    @s.browser.goto @path17
    @s.find("jest element")
    file = File.read(@path)
    expect(file.include?("Bye")).to be false
    @s.browser.goto @path18
    @s.find("jest element")
    @s.browser.goto @path17
    @s.find("jest element")
    file = File.read(@path)
    expect(file.include?("Bye")).to be true
  end

  after(:each) do
    File.delete(@path) if File.exist?(@path)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
    @s.browser.quit
  end
end
