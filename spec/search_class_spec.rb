require 'spec_helper'
describe "We can create Locatine::Search class" do
  context "with no options" do
    before(:all) do
      @dir = './Locatine_files/'
      @path = './Locatine_files/default.json'
      @s = Locatine::Search.new
    end
    it "has browser" do
      expect(@s.browser.class).to be == Watir::Browser
    end
    it "creates a file" do
      expect(File.exist?(@path)).to be true
    end
    it "has empty data" do
      expect(@s.data).to be == {}
    end
    it "has data with defaults" do
      expect(@s.data["ONE"]).to be == {}
      expect(@s.data["ONE"]["TWO"]).to be == {}
    end
    it "has correct learn mode" do
      expect(@s.learn).to be false
    end
    after(:all) do
      File.delete(@path) if File.exist?(@path)
      FileUtils.remove_dir(@dir) if File.directory?(@dir)
    end
  end
  context "with options" do
    before(:all) do
      @path = "./new_files/ooops.json"
      @dir = "./new_files/"
      @depth = 2
      @browser = Watir::Browser.new
      @learn = true
      @stability_limit = 9
      @scope = "Unknown"
      @s = Locatine::Search.new(json: @path,
                                depth: @depth,
                                browser: @browser,
                                learn: @learn,
                                stability_limit: @stability_limit,
                                scope: @scope)
    end
    it "creates a file" do
      expect(File.exist?(@path)).to be true
    end
    it "has options" do
      expect(@s.browser).to be == @browser
      expect(@s.json).to be == @path
      expect(@s.learn).to be == @learn
      expect(@s.stability_limit).to be == @stability_limit
      expect(@s.scope).to be == @scope
      expect(@s.depth).to be == @depth
    end
    it "has empty data" do
      expect(@s.data).to be == {}
    end
    after(:all) do
      File.delete(@path) if File.exist?(@path)
      FileUtils.remove_dir(@dir) if File.directory?(@dir)
    end
  end
  context "with data provided" do
    before(:all) do
      @path = './spec/test_data/dummy.json'
      @s = Locatine::Search.new(json: @path)
      @dir = './new_files/'
      @path2 = './new_files/deep/new.json'
    end
    it "has non-empty data" do
      expect(@s.data["A"]["B"]). to be == "c"
    end
    it "switches to a new file and back" do
      @s.json = @path2
      expect(File.exist?(@path2)).to be true
      expect(@s.data["A"]["B"]). to be == {}
      @s.json = @path
      expect(@s.data["A"]["B"]). to be == "c"
    end
    after(:all) do
      File.delete(@path2) if File.exist?(@path2)
      FileUtils.remove_dir(@dir) if File.directory?(@dir)
    end
  end
end
