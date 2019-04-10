require 'spec_helper'
describe 'Scope basic user story' do
  before(:all) do
    @path8 = "file://#{Dir.pwd}/spec/test_data/test-8.html"
    @dir = './Locatine_files/'
    @file = './Locatine_files/default.json'
    Watir.default_timeout = 3
  end
  before(:each) do
    @s = Locatine::Search.new
  end

  it "Can be used to define a scope" do
    @s.browser.quit
    @s.browser = Watir::Browser.new
    @s.learn = true
    @s.browser.goto @path8
    @s.get_scope(name: "test")
    @s.learn = false
    @s.scope = 'test'
    expect(@s.find("one span").exists?).to be == true
    expect(@s.find("two span").exists?).to be == true
    expect(@s.find("3 span").exists?).to be == true
    expect(@s.find("4 span").exists?).to be == true
    expect(@s.find("five span").exists?).to be == true
    expect(@s.data['test'].keys.last.include?('undescribed')).to be == true
    expect(@s.find(@s.data['test'].keys.last).exists?).to be == true
  end

  after(:all) do
    File.delete(@file) if File.exist?(@file)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
  end

  after(:each) do
    @s.browser.quit
  end
end
