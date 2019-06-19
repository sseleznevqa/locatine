require 'spec_helper'
describe 'Locatine trust sometimes' do
  before(:all) do
    @path13 = "file://#{Dir.pwd}/spec/test_data/test-13.html"
    @path14 = "file://#{Dir.pwd}/spec/test_data/test-14.html"
    @path15 = "file://#{Dir.pwd}/spec/test_data/test-15.html"
    @dir = './Locatine_files/'
    @file = './Locatine_files/default.json'
  end

  before(:each) do
    @s = Locatine::Search.new(autolearn: true)
  end

  it "learning to trust and untrust" do
    @s.untrusted = ['flaky']
    @s.browser.quit
    @s.learn = true
    @s.browser = Watir::Browser.new
    @s.browser.goto @path13
    expect(@s.find("flaky div").text).to be == "untrust me"
    expect(@s.find("lawful div").text).to be == "trust me"
  end

  it "untrusts correctly" do
    @s.browser.goto @path14
    expect(@s.find(name: "flaky div", exact: true).nil?).not_to be == true
    @s.trusted = ['stable']
    expect(@s.find("lawful div").text).to be == "trust me"
  end

  it "trusts correctly" do
    @s.browser.goto @path15
    expect(@s.find(name: "flaky div", exact: true).nil?).not_to be == true
    expect(@s.find(name: "lawful div", exact: true, no_fail: true).nil?).to be == true
  end

  after(:all) do
    File.delete(@file) if File.exist?(@file)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
  end
  after(:each) do
    @s.browser.quit
  end
end
