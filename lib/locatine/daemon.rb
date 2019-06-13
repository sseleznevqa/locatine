require 'sinatra/base'
require 'json'
require 'locatine/daemon_helpers'

module Locatine
  #
  # Locatine daemon based on sinatra
  #
  # run Locatine::Daemon.run!
  class Daemon < Sinatra::Base
    include Locatine::DaemonHelpers
    configure do
      set :search, nil
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

    post '/chromedriver' do
      Webdrivers::Chromedriver.required_version = params['version']
      { version: Webdrivers::Chromedriver.required_version }.to_json
    end

    get '/chromedriver' do
      { path: Webdrivers::Chromedriver.update }.to_json
    end

    post '/geckodriver' do
      Webdrivers::Geckodriver.required_version = params['version']
      { version: Webdrivers::Geckodriver.required_version }.to_json
    end

    get '/geckodriver' do
      { path: Webdrivers::Geckodriver.update }.to_json
    end

    post 'iedriver' do
      Webdrivers::IEdriver.required_version = params['version']
      { version: Webdrivers::IEdriver.required_version }.to_json
    end

    get '/iedriver' do
      { path: Webdrivers::IEdriver.update }.to_json
    end

    post '/connect' do
      steal
      { result: true }.to_json
    end

    post '/lctr' do
      data = Hash[params.map { |k, v| [k.to_sym, v] }]
      data.each { |k, v| data[k] = false if v == 'false' }
      search.lctr(data).to_json
    end

    post '/set' do
      hash = params
      search.json = hash['json'] if hash['json']
      warn 'You cannot set browser like this. Use /connect' if hash['browser']
      params.each_pair do |key, value|
        unless (key == 'browser') || (key == 'json')
          value = false if value == 'false'
          search.instance_variable_set("@#{key}", value)
        end
      end
      { result: true }.to_json
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
