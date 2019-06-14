require 'spec_helper'
require 'net/http'
require 'json'

def make_request(url, data = nil)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Get.new(uri.path)
  if data
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    req.body = data.to_json
  end
  res = http.request(req)
  JSON.parse(res.body)
end

describe 'Locatine daemon' do
  before(:all) do
    @path16 = "file://#{Dir.pwd}/spec/test_data/test-16.html"
    @dir = './Locatine_files/'
    @path = './Locatine_files/default.json'
  end

  before(:each) do
    @t = Thread.new do
      Locatine::Daemon.set :port, 7676
      Locatine::Daemon.set :show_exceptions, false
      Locatine::Daemon.run!
    end
    sleep 3
  end

  it 'downloads the geckodriver' do
    make_request("http://localhost:7676/geckodriver", {"version" => "0.23.0"})
    path = make_request("http://localhost:7676/geckodriver")["path"]
    expect(`#{path} --version`).to include "geckodriver 0.23.0"
  end

  it 'downloads the chromedriver' do
    path = make_request("http://localhost:7676/chromedriver")["path"]
    expect(File.file?(path)).to be true
  end

  it 'knows where we can find an app' do
    app = make_request("http://localhost:7676/app")["app"]
    b = Watir::Browser.new(:chrome, switches: ["--load-extension=#{app}"])
    b.goto "localhost:7676/app"
    sleep 1
    expect(b.element(id: 'locatine_magic_div').exists?).to be true
  end

  it 'can be used for learning' do
    #app = make_request("http://localhost:7676/app")["app"]
    b = Watir::Browser.new#(:chrome, switches: ["--load-extension=#{app}"])
    make_request("http://localhost:7676/set", {"learn" => "true"})
    victim_bridge = b.wd.send :bridge
    session_id = victim_bridge.instance_variable_get("@session_id")
    url = (victim_bridge.send(:http)).instance_variable_get("@server_url")
    make_request("http://localhost:7676/connect", {'browser' => 'chrome',
                                                   'session_id' => session_id,
                                                   'url' => url})
    b.goto @path16
    xpath = make_request("http://localhost:7676/lctr", {'name' => 'element to find'})["xpath"]
    expect(b.element(xpath: xpath).text).to eq "Hats off!"
  end

  it 'learns properly' do
    b = Watir::Browser.new :chrome
    victim_bridge = b.wd.send :bridge
    session_id = victim_bridge.instance_variable_get("@session_id")
    url = (victim_bridge.send(:http)).instance_variable_get("@server_url")
    make_request("http://localhost:7676/connect", {'browser' => 'chrome',
                                                   'session_id' => session_id,
                                                   'url' => url})
    b.goto @path16
    xpath = make_request("http://localhost:7676/lctr", {'name' => 'element to find'})["xpath"]
    expect(b.element(xpath: xpath).text).to eq "Hats off!"
  end


  after(:each) do
    puts make_request("http://localhost:7676/stop")
    sleep 3
    @t.join
  end

  after(:all) do
    File.delete(@path) if File.exist?(@path)
    FileUtils.remove_dir(@dir) if File.directory?(@dir)
  end
end
