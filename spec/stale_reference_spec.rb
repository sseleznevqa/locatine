# frozen_string_literal: true

require 'spec_helper'

# Getting there!
finders = {}
Selenium::WebDriver::SearchContext::FINDERS.each_pair do |key, value|
  finders[key] = value
end
finders[:locatine] = 'locatine'
Selenium::WebDriver::SearchContext::FINDERS = finders.freeze

describe 'locatine' do
  before(:all) do
    @t = Thread.new do
      Locatine::Daemon.set :port, 7733
      Locatine::Daemon.set :show_exceptions, false
      Locatine::Daemon.run!
    end
    sleep 10
    Watir.default_timeout = 30
  end

  before(:each) do
    @b = Watir::Browser.new :chrome, timeout: 120,
                                     url: 'http://localhost:7733/wd/hub'
    @d = @b.driver
  end

  it 'nested elements' do
    @b.goto page 12
    @d.find_element(locatine: 'something to find span')
    @b.goto page 15
    expect(@d.find_element(locatine: 'something to find span').text)
      .to eq 'Check text'
  end

  seed = rand(1_000_000)
  it "handling stale element reference (seed == #{seed})" do
    random = Random.new(seed)
    array = Array.new(10_000) { random.rand }
    @b.goto page 12
    @d.find_element(locatine: 'something to find span')
    @b.goto page 13
    @d.execute_script('document.randoms = arguments[0]', array)
    sleep 5
    expect(@d.find_element(locatine: 'something to find span').text)
      .to eq 'Check text'
  end

  seed = rand(1_000_000)
  it "finds untouched element on changing page" do
    random = Random.new(seed)
    array = Array.new(10_000) { random.rand }
    @b.goto page 12
    @d.find_element(locatine: 'something to find span')
    @b.goto page 14
    @d.execute_script('document.randoms = arguments[0]', array)
    sleep 5
    expect(@d.find_element(locatine: 'something to find span').
                                    text.include?('Check text')).to eq true
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
