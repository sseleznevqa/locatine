require 'spec_helper'
describe 'Scope basic user story' do
  before(:all) do
    @path8 = "file://#{Dir.pwd}/spec/test_data/test-8.html"
    @path9 = "file://#{Dir.pwd}/spec/test_data/test-9.html"
    @path10 = "file://#{Dir.pwd}/spec/test_data/test-10.html"
    @dir = './Locatine_files/'
    @file = './Locatine_files/default.json'
    @xpath = "//*[self::div]/*[self::div]/*[self::span][contains(@name, 'two')][not(@id = 'locatine_magic_div')]"
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
  end

  it "Can be used to redefine a scope" do
    @s.browser.quit
    @s.browser = Watir::Browser.new
    @s.learn = true
    @s.browser.goto @path10
    @s.get_scope(name: "test")
    @s.learn = false
    @s.scope = 'test'
    expect(@s.find("one span").text).to be == ''
    expect(@s.find("two span").exists?).to be == true
    expect(@s.find("3 span").exists?).to be == true
    expect(@s.find("4 span").exists?).to be == true
    expect(@s.find("five span").exists?).to be == true
    expect(@s.data['test'].keys.last.include?('undescribed')).to be == true
    expect(@s.find(@s.data['test'].keys.last).exists?).to be == true
  end

  it "can be used to find all elements at once" do
    @s.browser.goto @path9
    all = @s.get_scope(name: "test").all
    expect(all.length).to be == 6
    expect(all["two span"][:elements][0].class).to be == Watir::Span
    expect(all["two span"][:locator][:xpath]).to be == @xpath
  end

  it "can be used to check element presence" do
    @s.browser.goto @path9
    all = @s.get_scope(name: "test").check
    expect(all.length).to be == 6
    @s.browser.execute_script("document.getElementById('one').setAttribute('id','lost')")
    expect{@s.get_scope(name: "test").check}.to raise_error(RuntimeError, "Check of test failed! Lost: [\"one span\"]")
    all = @s.get_scope(name: "test").all
    expect(all["one span"][:elements].length).to be == 7
  end

  after(:all) do
    File.delete(@file) if File.exist?(@file)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
  end

  after(:each) do
    @s.browser.quit
  end
end
