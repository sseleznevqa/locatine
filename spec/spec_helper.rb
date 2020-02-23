# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
require 'rspec'
require './lib/locatine'
require 'watir'
require 'webdrivers'
require 'pry'

def make_request(url, method = 'Get', data = nil)
  uri = URI(url)
  req = Net::HTTP.const_get(method).new(uri.path)
  if data
    req = Net::HTTP.const_get(method).new(uri.path,
                                          'Content-Type' => 'application/json')
    req.body = data.to_json
  end
  JSON.parse(Net::HTTP.new(uri.host, uri.port).request(req).body)
end

def page(number)
  "file://#{Dir.pwd}/spec/test_pages/page#{number}.html"
end
