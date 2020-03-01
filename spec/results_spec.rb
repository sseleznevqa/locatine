# frozen_string_literal: true

require 'spec_helper'
describe 'results logic' do
  before(:each) do
    @results = Locatine::Results.new
  end

  it 'sums' do
    @results.push([{ 'name' => '1', 'type' => '1', 'value' => '1' },
                   { 'name' => '2', 'type' => '2', 'value' => '2' }])
    @results.push([{ 'name' => '1', 'type' => '1', 'value' => '1' },
                   { 'name' => '3', 'type' => '3', 'value' => '3' }])
    first = @results.info_sum(@results.first, @results.first)
    second = @results.info_sum(@results.first, @results[1])
    expect(first).to eq @results.first
    expect(second).to eq [{ 'name' => '1', 'type' => '1', 'value' => '1' }]
  end

  it 'checking equal' do
    expect(@results.info_hash_eq({ 'name' => '1', 'type' => '1',
                                   'value' => '1', 'a' => 'b' },
                                 'name' => '1', 'type' => '1',
                                 'value' => '1', 'b' => 'c')).to eq true
  end

  it 'checking not equal' do
    expect(@results.info_hash_eq({ 'name' => '1', 'type' => '1',
                                   'value' => '1', 'a' => 'b' },
                                 'name' => '1', 'type' => '1',
                                 'value' => '2', 'a' => 'b')).to eq false
  end

  it 'checking unknown equal' do
    expect(@results.info_hash_eq({ 'name' => '*', 'type' => '*',
                                   'value' => 's', 'a' => 'b' },
                                 'name' => '1', 'type' => '1',
                                 'value' => 'S', 'b' => 'c')).to eq true
  end

  it 'checking unknown not equal' do
    expect(@results.info_hash_eq({ 'name' => '*', 'type' => '*',
                                   'value' => '1', 'a' => 'b' },
                                 'name' => '1', 'type' => '1',
                                 'value' => '2', 'b' => 'c')).to eq false
  end

  it 'generates xpath' do
    str = "//*[self::vid][contains(@rtta, 'rtta')][contains(text(), 'txet')]"\
          "/*[self::div][contains(@attr, 'attr')][contains(text(), 'text')]"
    @results.instance_variable_set('@config', 'untrusted' => [])
    expect(@results.generate_xpath('0': [{ 'name' => 'text',
                                           'value' => 'text',
                                           'type' => 'text' },
                                         { 'name' => 'attr',
                                           'type' => 'attribute',
                                           'value' => 'attr' },
                                         { 'name' => 'tag',
                                           'type' => 'tag',
                                           'value' => 'div' }],
                                   '1': [{ 'name' => 'text',
                                           'value' => 'txet',
                                           'type' => 'text' },
                                         { 'name' => 'rtta',
                                           'type' => 'attribute',
                                           'value' => 'rtta' },
                                         { 'name' => 'tag',
                                           'type' => 'tag',
                                           'value' => 'vid' }])).to eq str
  end
end
