require 'spec_helper'
describe 'Crazy cases' do
  before(:all) do
    @path11 = "file://#{Dir.pwd}/spec/test_data/test-11.html"
    @path12 = "file://#{Dir.pwd}/spec/test_data/test-12.html"
    @dir = './Locatine_files/'
    @file = './Locatine_files/default.json'
  end

  before(:each) do
    @s = Locatine::Search.new
  end

  it "works with twins" do
    @s.browser.quit
    @s.learn = true
    @s.browser = Watir::Browser.new
    @s.browser.goto @path11
    expect(@s.find("second twin").text).to be == "ONE"
    @s.browser.goto @path12
    @s.learn = false
    expect(@s.find("second twin")).not_to be == @s.browser.form.li
  end

  it "stores twins normally" do
    @s.browser.goto @path12
    expect(@s.find("second twin")).not_to be == @s.browser.form.li
  end

  after(:all) do
    File.delete(@file) if File.exist?(@file)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
  end
  after(:each) do
    @s.browser.quit
  end
end
