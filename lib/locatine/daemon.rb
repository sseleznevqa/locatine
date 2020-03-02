# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Locatine
  #
  # Locatine daemon based on sinatra
  #
  # run Locatine::Daemon.run!
  class Daemon < Sinatra::Base
    include Locatine::DaemonHelpers::Methods

    configure do
      set :sessions, {}
      set :selenium, ENV['SELENIUM'] || 'http://localhost:4444'
      set :headers, 'Content-Type' => 'application/json'
      set :port, 7733
    end

    # own calls
    get '/' do
      redirect 'https://github.com/sseleznevqa/locatine'
    end

    get '/locatine/stop' do
      Locatine::Daemon.quit!
      { result: 'dead' }.to_json
    end

    post '/locatine/session/*' do
      session = request.path_info.split('/').last
      result = settings.sessions[session].configure(params)
      { result: result }.to_json
    end

    # selenium calls
    post '/wd/hub/session/*/element' do
      content_type settings.headers['Content-Type']
      results = settings.sessions[session_id].find(params, element_id)
      status 200
      results.empty? ? raise_not_found : { value: results.first.answer }.to_json
    end

    post '/wd/hub/session/*/elements' do
      content_type settings.headers['Content-Type']
      results = settings.sessions[session_id].find(params, element_id)
      status 200
      answer = results.empty? ? [] : results.map(&:answer)
      { value: answer }.to_json
    end

    post '/wd/hub/session' do
      result = call_process('post')
      the_session = JSON.parse(result)['value']['sessionId']
      caps = params['desiredCapabilities']
      locatine_caps = caps['locatine'] if caps
      settings.sessions[the_session] = Locatine::Session
                                       .new(selenium, the_session)
      settings.sessions[the_session].configure(locatine_caps)
      result
    end

    delete '/wd/hub/session/*' do
      settings.sessions[session_id] = nil
      call_process('delete')
    end

    %w[get post put patch delete].each do |verb|
      send(verb, '/wd/hub/*') do
        call_process(verb)
      end
    end
  end
end
