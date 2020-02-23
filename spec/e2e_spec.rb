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

  it 'can pass vars to locatine via capabilities' do
    @b.quit
    @b = Watir::Browser.new :chrome,
                            timeout: 120, url: 'http://localhost:7733/wd/hub',
                            locatine: { json: './locatine_files/e2e.json' }
    hash = JSON.parse(File.read('./locatine_files/e2e.json'))['elements']
    expect(hash).to eq({})
  end

  it 'cannot find element (if it is not here)' do
    expect do
      @b.element(xpath: '//div')
        .locate.click
    end
      .to raise_error Watir::Exception::UnknownObjectException
  end

  it 'can find element' do
    @b.goto page(1)
    @b.element(xpath: '//div').locate.click
  end

  it 'stores element' do
    file = File.read('./locatine_files/default.json')
    data = JSON.parse(file)
    check = data['elements']['//div']['0'].include?('name' => 'text',
                                                    'value' => 'Something',
                                                    'type' => 'text',
                                                    'stability' => 1)
    expect(check).to eq true
  end

  it 'bumps stability' do
    @b.goto page(1)
    @b.element(xpath: '//div').locate.click
    file = File.read('./locatine_files/default.json')
    data = JSON.parse(file)
    check = data['elements']['//div']['0'].include?('name' => 'text',
                                                    'value' => 'Something',
                                                    'type' => 'text',
                                                    'stability' => 2)
    expect(check).to eq true
  end

  it 'doesnt trust' do
    @b.goto page(1)
    config = { untrusted: ['text'] }.to_json
    @b.element(xpath: "//div['#{config}']").locate.click
    file = File.read('./locatine_files/default.json')
    data = JSON.parse(file)
    check = data['elements']['//div']['0'].include?('name' => 'text',
                                                    'value' => 'Something',
                                                    'type' => 'text',
                                                    'stability' => 0)
    expect(check).to eq true
  end

  it 'trusts' do
    @b.goto page(1)
    config = { trusted: ['text'] }.to_json
    @b.element(xpath: "//div['#{config}']").locate.click
    file = File.read('./locatine_files/default.json')
    data = JSON.parse(file)
    check = data['elements']['//div']['0'].include?('name' => 'text',
                                                    'value' => 'Something',
                                                    'type' => 'text',
                                                    'stability' => 4)
    expect(check).to eq true
  end

  it 'doesnt trust' do
    @b.goto page(1)
    config = { untrusted: ['text'] }.to_json
    @b.element(xpath: "//div['#{config}']").locate.click
    file = File.read('./locatine_files/default.json')
    data = JSON.parse(file)
    check = data['elements']['//div']['0'].include?('name' => 'text',
                                                    'value' => 'Something',
                                                    'type' => 'text',
                                                    'stability' => 0)
    expect(check).to eq true
  end

  it 'reads attributes' do
    @b.goto page(1)
    element = @b.element(xpath: '//div')
    @b.execute_script("arguments[0].setAttribute('id', '');", element)
    @b.element(xpath: '//div').locate.click
    file = File.read('./locatine_files/default.json')
    check = file.include?('yyy')
    expect(check).to eq false
  end

  it 'finds by remembered data' do
    @b.goto page(1)
    config = { name: 'test' }.to_json
    @b.element(xpath: "//div['#{config}']").locate.click
    expect(@b.element(xpath: "['test']").text).to eq 'Something'
  end

  it 'uses magic find' do
    @b.goto page(2)
    expect(@b.element(xpath: "['test']").text).to eq 'Something'
  end

  it 'uses magic find(without success)' do
    @b.goto page(3)
    expect do
      @b.element(xpath: "['test']")
        .locate.click
    end
      .to raise_error Watir::Exception::UnknownObjectException
  end

  it 'finds a collection' do
    @b.goto page(4)
    expect(@b.elements(css: '.gru.brr/*collection*/').length).to eq 3
  end

  it 'finds a collection via magic' do
    @b.goto page(5)
    expect(@b.elements(css: '.gru.brr/*collection*/').length).to eq 3
    expect(@b.elements(css: '/*collection*/')[0].tag_name.downcase).to eq 'span'
  end

  it 'may use a locatine for search' do
    @b.goto page(5)
    @b.driver.find_element(locatine: 'collection')
  end

  it 'may use a locatine for search' do
    file = File.read('./locatine_files/default.json')
    data = JSON.parse(file)
    check = data['elements']['collection']['3'].nil?
    expect(check).to eq false
    @b.goto page(5)
    params = { name: 'collection', depth: 1 }.to_json
    @b.driver.find_element(locatine: params)
    file = File.read('./locatine_files/default.json')
    data = JSON.parse(file)
    check = data['elements']['collection']['1'].nil?
    expect(check).to eq false
    check = data['elements']['collection']['2'].nil?
    expect(check).to eq true
  end

  it 'finds exactly collection' do
    @b.goto page(6)
    expect(@b.elements(css: '/*exactly collection*/').length).to eq 0
    expect(@b.elements(css: '/*collection*/').length).to eq 3
  end

  it 'finds based on stability' do
    @b.goto page(7)
    10.times do
      expect(@b.elements(css: '/*exactly collection*/').length).to eq 3
    end
    @b.goto page(6)
    expect(@b.elements(css: '/*exactly collection*/').length).to eq 0
  end

  it 'finds something if it has time' do
    @b.goto page(6)
    params = { name: 'collection', timeout: 0.01 }.to_json
    expect(@b.elements(css: "/*#{params}*/").length).to eq 0
    expect(@b.elements(css: '/*collection*/').length).to eq 3
  end

  it 'seriously trusts' do
    @b.goto page(1)
    params = { name: 'Something', tolerance: 0, trusted: ['class'] }.to_json
    @b.element(css: "/*#{params}*/").locate.click
    @b.goto page(2)
    expect(@b.element(css: "/*#{params}*/").text).to eq 'Something'
  end

  it 'untrusts even when element is lost' do
    @b.goto page(9)
    params = { name: 'aaa kkk', untrusted: ['class'] }.to_json
    @b.driver.find_element(locatine: params)
    @b.goto page(10)
    expect(@b.driver.find_element(locatine: params).text).to eq 'Other'
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
