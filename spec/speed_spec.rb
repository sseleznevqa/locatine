# frozen_string_literal: true

require 'spec_helper'

# Getting there!
finders = {}
Selenium::WebDriver::SearchContext::FINDERS.each_pair do |key, value|
  finders[key] = value
end
finders[:locatine] = 'locatine'
Selenium::WebDriver::SearchContext::FINDERS = finders.freeze

describe 'doing' do
  before(:all) do
    @t = Thread.new do
      Locatine::Daemon.set :port, 7733
      Locatine::Daemon.set :show_exceptions, false
      Locatine::Daemon.run!
    end
    sleep 10
    Watir.default_timeout = 30
  end

  it 'Speed test' do
    @b = Watir::Browser.new :chrome, timeout: 120,
                                     url: 'http://localhost:7733/wd/hub'
    @d = @b.driver
    @b.goto page 11
    t = Time.now
    1000.times do
      @d.find_element(xpath: "//div[@id = 'xxx yyy']")
    end
    puts Time.now - t
  end

  it 'Speed test-2' do
    @b = Watir::Browser.new :chrome, timeout: 120,
                                     url: 'http://localhost:4444/wd/hub'
    @d = @b.driver
    @b.goto page 11
    t = Time.now
    1000.times do
      @d.find_element(xpath: "//div[@id = 'xxx yyy']")
    end
    puts Time.now - t
  end

  after(:all) do
    FileUtils.remove_dir('./locatine_files/', true)
    make_request('http://localhost:7733/locatine/stop')
    sleep 3
    @t.join
  end

  after(:each) do
    @b.quit
  end
end
