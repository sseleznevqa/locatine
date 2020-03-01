# frozen_string_literal: true

require 'spec_helper'

# Getting there!
module Selenium
  module WebDriver
    module SearchContext
      FINDERS = {
        class: 'class name',
        class_name: 'class name',
        css: 'css selector',
        id: 'id',
        link: 'link text',
        link_text: 'link text',
        locatine: 'locatine', # Here we are!
        name: 'name',
        partial_link_text: 'partial link text',
        relative: 'relative',
        tag_name: 'tag name',
        xpath: 'xpath'
      }.freeze
    end
  end
end

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
