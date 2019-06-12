require 'sinatra/base'
require 'json'

#run Locatine::Daemon.run!
module Locatine
  class Daemon < Sinatra::Base
    configure do
      set :search, nil
    end

    get "/app" do
      {app: File.join(Locatine::HOME, "app").to_s}.to_json
    end

    get "/" do
      redirect "https://github.com/sseleznevqa/locatine#using-as-a-daemon"
    end

    get "/stop" do
      Locatine::Daemon.quit!
      {result: "dead"}.to_json
    end

    post "/chromedriver" do
      Webdrivers::Chromedriver.required_version = params['version']
      {version: Webdrivers::Chromedriver.required_version}.to_json
    end

    get "/chromedriver" do
      {path: Webdrivers::Chromedriver.update}.to_json
    end

    post "/geckodriver" do
      Webdrivers::Geckodriver.required_version = params['version']
      {version: Webdrivers::Geckodriver.required_version}.to_json
    end

    get "/geckodriver" do
      {path: Webdrivers::Geckodriver.update}.to_json
    end

    post "iedriver" do
      Webdrivers::IEdriver.required_version = params['version']
      {version: Webdrivers::IEdriver.required_version}.to_json
    end

    get "/iedriver" do
      {path: Webdrivers::IEdriver.update}.to_json
    end

    post "/connect" do
      #Stealing browser
      search.browser = Watir::Browser.new(params['browser'].to_sym)

      search.browser.quit
      search.browser.instance_variable_set("@closed", false)

      search.browser.wd.send(:bridge).instance_variable_set("@session_id", params['session_id'])
      parsed = URI.parse(params['url'])
      search.browser.wd.send(:bridge).send(:http).instance_variable_set("@server_url", parsed)
      net = Net::HTTP.new("#{parsed.host}#{(parsed.path== '/') ? '' : parsed.path}", parsed.port)
      search.browser.wd.send(:bridge).send(:http).instance_variable_set("@http", net)
      search.browser.wd.send(:bridge).send(:http).instance_variable_set("@proxy", params['proxy']) unless params['proxy'].to_s.empty?
      {result: true}.to_json
    end

    post "/lctr" do
      data = params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      data.each { |k, v| data[k] = false if v == "false" }
      search.lctr(data).to_json
    end

    post "/set" do
      search
      params.each_pair do |key, value|
        case key
        when 'json'
          search.json = value
        when 'browser'
          warn 'You cannot set browser like this. Use /connect'
        else
          value = false if value == "false"
          search.instance_variable_set("@#{key}", value)
        end
      end
      {result: true}.to_json
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
