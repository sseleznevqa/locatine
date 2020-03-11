# frozen_string_literal: true

require 'spec_helper'
describe 'session basically' do
  before(:each) do
    @session = Locatine::Session.new('selenium', 'session')
  end

  it 'inits' do
    expect(@session.instance_variable_get('@selenium')).to eq 'selenium'
    expect(@session.instance_variable_get('@session')).to eq 'session'
  end

  it 'inits with defauts' do
    expect(@session.json).to eq Dir.pwd + '/locatine_files/default.json'
    expect(@session.depth).to eq 3
    expect(@session.trusted).to eq []
    expect(@session.untrusted).to eq []
    expect(@session.tolerance).to eq 50
    expect(@session.stability).to eq 10
    expect(@session.timeout).to eq 25
  end

  it 'creates file' do
    hash = JSON.parse(File.read('./locatine_files/default.json'))['elements']
    expect(hash).to eq({})
  end

  it 'writes files' do
    @session.instance_variable_set('@elements', 'hey' => %w[1 2])
    @session.send :write
    hash = JSON.parse(File.read('./locatine_files/default.json'))['elements']
    expect(hash['hey']).to eq(%w[1 2])
  end

  it 'can be configured' do
    @session.configure(json: './locatine_files/new.json', depth: 0,
                       trusted: ['one'], untrusted: ['two'], tolerance: 0,
                       stability: 5, timeout: 10)
    expect(@session.json).to eq './locatine_files/new.json'
    expect(@session.depth).to eq 0
    expect(@session.trusted).to eq ['one']
    expect(@session.untrusted).to eq ['two']
    expect(@session.tolerance).to eq 0
    expect(@session.stability).to eq 5
    expect(@session.timeout).to eq 10
    hash = JSON.parse(File.read('./locatine_files/new.json'))['elements']
    expect(hash).to eq({})
  end

  after(:all) do
    FileUtils.remove_dir('./locatine_files/', true)
  end
end
