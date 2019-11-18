require 'sinatra/base'
require 'json'
require 'locatine/daemon_helpers'
require 'pry'

module Locatine
  #
  # Locatine daemon based on sinatra
  #
  # run Locatine::Daemon.run!
  class Daemon < Sinatra::Base
    include Locatine::DaemonHelpers
    configure do
      set :search, nil
      set :selenium, ENV['SELENIUM'] || "http://localhost:4444"
      set :headers, { "Content-Type" => "application/json" }
    end

    get '/app' do
      { app: File.join(Locatine::HOME, 'app').to_s }.to_json
    end

    get '/' do
      redirect 'https://github.com/sseleznevqa/locatine#using-as-a-daemon'
    end

    get '/stop' do
      Locatine::Daemon.quit!
      { result: 'dead' }.to_json
    end

    post '/set' do
      hash = params
      search.json = hash['json'] if hash['json']
      selenium = hash['selenium'] if hash['selenium']
      warn 'You cannot set browser like this. Use /connect' if hash['browser']
      params.each_pair do |key, value|
        unless (key == 'browser') || (key == 'json')
          value = false if value == 'false'
          search.instance_variable_set("@#{key}", value)
        end
      end
      { result: true }.to_json
    end

    # methods
    def api_request(type, path, query_string, body, new_headers)
      parsed = URI.parse selenium
      uri = URI::HTTP.build(
          host: parsed.host,
          port: parsed.port,
          path: path,
          query: query_string
      )
      req = Net::HTTP.const_get(type).new(uri, settings.headers.merge(new_headers))
      req.body = body.read
      Net::HTTP.new(uri.hostname, uri.port).start {|http| http.request(req) }
    end

    def all_headers(response)
      header_list = {}
      response.header.each_capitalized do |k,v|
        header_list[k] =v unless k == "Transfer-Encoding"
      end
      header_list
    end

    def incomming_headers(request)
      request.env.map { |header, value|  [header[5..-1].split("_").map(&:capitalize).join('-'), value] if header.start_with?("HTTP_") }.compact.to_h
    end

    %w(get post put patch delete).each do |verb|
      send(verb, "/selenium*") do
        path = request.path_info.sub("/selenium", '')
        content_type settings.headers["Content-Type"]
        start_request = Thread.new {
          api_request(verb.capitalize, path, request.query_string, request.body, incomming_headers(request))
        }
        response = start_request.value
        status response.code
        headers all_headers(response)
        response.body
      end
    end

    def selenium
      settings.selenium
    end

    def search
      return settings.search unless settings.search.nil?

      settings.search = Locatine::Search.new
      settings.search.browser.quit
      settings.search
    end

    def params
      request.body.rewind
      JSON.parse request.body.read
    end
  end
end
