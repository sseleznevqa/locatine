# frozen_string_literal: true

require 'spec_helper'

# Getting there!
finders = {}
Selenium::WebDriver::SearchContext::FINDERS.each_pair do |key, value|
  finders[key] = value
end
finders[:locatine] = 'locatine'
Selenium::WebDriver::SearchContext::FINDERS = finders.freeze

describe 'user' do
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
  end

  it 'finds something by guess' do
    @b.goto page(8)
    expect(@b.driver
              .find_element(locatine: 'number one div').text).to eq 'Gotcha!'
    expect(@b.driver.find_elements(locatine: 'collection span').length).to eq 3
  end

  it 'fails to find anyting if there is nothing' do
    @b.goto page(16)
    expect { @b.driver.find_element(locatine: 'never span') }
      .to raise_error Selenium::WebDriver::Error::NoSuchElementError
    expect(@b.driver.find_elements(locatine: 'nothing label').length).to eq 0
  end

  it 'fails to find anyting if there is something strange' do
    @b.goto page(16)
    expect { @b.driver.find_element(locatine: 'strange one') }
      .to raise_error Selenium::WebDriver::Error::NoSuchElementError
    expect(@b.driver.find_elements(locatine: 'not good').length).to eq 0
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
