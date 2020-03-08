# frozen_string_literal: true

module Locatine
  #
  # Locatine session operator finds and returns
  class Session
    include Locatine::Logger
    attr_accessor :json, :depth, :trusted, :untrusted, :tolerance, :stability,
                  :elements, :timeout

    def defaults
      { json: "#{Dir.pwd}/locatine_files/default.json", depth: 3, trusted: [],
        untrusted: [], tolerance: 50, stability: 10, timeout: 25 }
    end

    def initialize(selenium, session)
      @selenium = selenium
      @parsed_selenium = URI.parse @selenium
      @session = session
      @elements = []
      @threads = []
      # defaults
      configure defaults
    end

    def configure(params)
      params.to_h.each_pair do |var, value|
        instance_variable_set("@#{var}", value)
        read if var.to_s == 'json'
      end
      params
    end

    def read
      dir = File.dirname(@json)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      unless File.exist?(@json)
        File.open(@json, 'w') do |f|
          f.write('{"elements" : {}}')
        end
      end
      @elements = JSON.parse(File.read(@json))['elements']
    end

    def write
      File.open(@json, 'w') do |f|
        f.write(JSON.pretty_generate('elements' => @elements))
      end
    end

    def find(params, parent = nil)
      find_routine(params, parent)
    rescue RuntimeError => e
      raise e.message unless e.message == 'stale element reference'

      warn_unstable_page
      find(params, parent)
    end

    def find_routine(params, parent)
      results = Results.new
      results.configure(self, params, parent)
      answer = results.find
      if !answer.empty? && answer.first.class != Locatine::Error
        @elements[results.name] = results.info
        write
      end
      answer
    end

    def execute_script(script, *args)
      args.map! { |item| item.class == Locatine::Element ? item.answer : item }
      response = api_request('/execute/sync', 'Post',
                             { script: script, args: args }.to_json).body
      value = JSON.parse(response, max_nesting: false)['value']
      error_present = (value.class == Hash) && value['error']
      raise_script_error(script, args, value) if error_present

      value
    end

    def page
      # We need duplicated JSON parse since standart
      # chromedriver giving an error here if the page is too large
      page = execute_script(File.read("#{HOME}/scripts/page.js"))
      JSON.parse(page, max_nesting: false)['result']
    end

    def call_uri(path)
      URI::HTTP.build(
        host: @parsed_selenium.host,
        port: @parsed_selenium.port,
        path: "/wd/hub/session/#{@session}#{path}"
      )
    end

    def api_request(path, method, body)
      uri = call_uri(path)
      req = Net::HTTP.const_get(method)
                     .new(uri,
                          "Content-Type": 'application/json; charset=utf-8',
                          "Cache-Control": 'no-cache')
      req.body = body
      Net::HTTP.new(uri.hostname, uri.port).start { |http| http.request(req) }
    end
  end
end
