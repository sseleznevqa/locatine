# frozen_string_literal: true

require 'spec_helper'
describe 'daemon' do
  before(:all) do
    @t = Thread.new do
      Locatine::Daemon.set :port, 7733
      Locatine::Daemon.set :show_exceptions, false
      Locatine::Daemon.run!
    end
    sleep 3
  end
  it 'like a proxy' do
    s = make_request('http://localhost:7733/wd/hub/session', 'Post',
                     "capabilities": {
                       "alwaysMatch": {
                         "browserName": 'chrome'
                       }
                     })
    session_id = s['value']['sessionId']
    expect(
      make_request(
        "http://localhost:4444/wd/hub/session/#{session_id}/url", 'Get'
      )['value']
    )
      .to eq 'data:,'
    make_request("http://localhost:7733/wd/hub/session/#{session_id}",
                 'Delete')
    expect(
      make_request(
        "http://localhost:4444/wd/hub/session/#{session_id}/url", 'Delete'
      )['value']['error']
    )
      .to eq 'invalid session id'
  end

  it 'session could be configured' do
    s = make_request('http://localhost:7733/wd/hub/session', 'Post',
                     "capabilities": {
                       "alwaysMatch": {
                         "browserName": 'chrome'
                       }
                     })
    session_id = s['value']['sessionId']
    make_request(
      "http://localhost:7733/locatine/session/#{session_id}", 'Post',
      json: './daemon.json'
    )
    make_request("http://localhost:7733/wd/hub/session/#{session_id}",
                 'Delete')
    expect(File.file?('./daemon.json')).to eq true
  end

  it 'stops' do
    make_request('http://localhost:7733/locatine/stop', 'Get')
    expect { make_request('http://localhost:7733/') }
      .to raise_error(Errno::ECONNREFUSED)
  end
end
