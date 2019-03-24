require 'spec_helper'

def set_attr(element, name, value)
  @b.execute_script("arguments[0].setAttribute(arguments[1], arguments[2])", element, name, value)
  sleep 0.2
end
describe 'Testing js via ruby' do
  context 'content.js' do
    before(:each) do
      @s = Locatine::Search.new
      @b = @s.browser
      @path = "file://#{Dir.pwd}/spec/test_data/content.html"
      @b.goto @path
      sleep 0.2
      @magic_div = @b.div(id: "locatine_magic_div")
      @pseudo_click = %Q[
          let ev = document.createEvent("MouseEvent");
          let magic_div  = document.getElementById('locatine_magic_div');
          ev.initMouseEvent(
              "click",
              true, true,
              window, null,
              arguments[0], arguments[1], arguments[0], arguments[1],
              false, false, false, false,
              0, null
          );
          magic_div.dispatchEvent(ev);]
    end

    it 'is creating magic div' do
      expect(@magic_div.exists?).to be true
      expect(@magic_div.attribute("locatinestyle")).to be == "undefined"
      expect(@magic_div.attribute("locatinetitle")).to be == "ok"
      expect(@magic_div.attribute("locatinehint")).to be == "ok"
    end

    it 'is turning magic div on' do
      set_attr(@magic_div, "locatinestyle", "set_true")
      expect(@magic_div.attribute("locatinestyle")).to be == "true"
      expect{@b.span.click}.to raise_error(Selenium::WebDriver::Error::UnknownError)
    end

    it 'is turninng magic div off' do
      set_attr(@magic_div, "locatinestyle", "set_false")
      expect(@magic_div.attribute("locatinestyle")).to be == "false"
      expect{@b.span.click}.to_not raise_error
    end

    it 'can return element selected under magic div' do
      set_attr(@magic_div, "locatinestyle", "set_true")
      location = @b.span.location
      @b.execute_script(@pseudo_click, location.x, location.y)
      sleep 1
      expect(@magic_div.attribute("tag")).to be == "SPAN"
      expect(@magic_div.attribute("index")).to be == "0"
    end

    after(:each) do
      @b.quit
    end
  end
end
