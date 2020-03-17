# frozen_string_literal: true

module Locatine
  ##
  # Locatine Session class.
  #
  # Each selenium session gets a locatine session. Locatine session knows
  # selenium address and session_id so it is able to communicate with selenium.
  # It has no complex logic, but acts like a bridge between daemon and selenium
  # while element is searched
  class Session
    include Locatine::Logger
    attr_accessor :json, :depth, :trusted, :untrusted, :tolerance, :stability,
                  :elements, :timeout

    ##
    # Init of the new session instance
    #
    # @param selenium [String] is a selenium address like +"https://host:port"+
    # @param session [String] is a session id provided by selenium
    def initialize(selenium, session)
      @selenium = selenium
      @parsed_selenium = URI.parse @selenium
      @session = session
      @elements = []
      @threads = []
      # defaults
      configure defaults
    end

    ##
    # This method is to set settings
    #
    # @param params [Hash] is for settings like +{json: "some", depth: 0...}+
    # @return params hash :)
    def configure(params)
      params.to_h.each_pair do |var, value|
        instance_variable_set("@#{var}", value)
        read if var.to_s == 'json'
      end
      params
    end

    ##
    # Find method is for finding elements.
    #
    # That is the part that is replacing simple finding by selenium
    # @param params [Hash] is for settings like +{json: "some", depth: 0...}+
    # @param parent [String] is an element code of the element to look under.
    #   It is counted
    #   only for the most simple search. If element is lost parent will be
    #   ignored
    # @return populated instance of Locatine::Results or an empty array
    #   or Locatine::Error
    def find(params, parent = nil)
      @start_time = Time.now
      find_routine(params, parent)
    rescue RuntimeError => e
      raise e.message unless e.message == 'stale element reference'

      warn_unstable_page
      find_routine(params, parent)
    end

    ##
    # Session can execute js scripts on a page
    #
    # @note This method will be not called when you are asking selenum via
    #   locatine to execute a script. This method is for internal use only.
    # @param script [String] some valid js code
    # @param *args [Array] arguments to be passed to script.
    def execute_script(script, *args)
      args.map! { |item| item.class == Locatine::Element ? item.answer : item }
      response = api_request('/execute/sync', 'Post',
                             { script: script, args: args }.to_json).body
      value = JSON.parse(response, max_nesting: false)['value']
      error_present = (value.class == Hash) && value['error']
      raise_script_error(script, args, value) if error_present

      value
    end

    ##
    # Returning information about the current page
    def page
      # We need duplicated JSON parse since standart
      # chromedriver giving an error here if the page is too large
      page = execute_script(File.read("#{HOME}/scripts/page.js"))
      JSON.parse(page, max_nesting: false)['result']
    end

    ##
    # This method is used to ask selenium about something.
    #
    # We are using it to ask for elements found by selenium or
    # for script execution
    # @param path [String] is a relative path to call on selenium like
    #   +'/elements'+
    # @param method [String] is an http method to perform ( +'Get'+, +'Post'+,
    #   etc.)
    # @param body [String] is for request data. Json here (selenium wants it)
    #   or nil
    # @return result of call whatever it is
    def api_request(path, method, body)
      uri = call_uri(path)
      req = Net::HTTP.const_get(method)
                     .new(uri,
                          "Content-Type": 'application/json; charset=utf-8',
                          "Cache-Control": 'no-cache')
      req.body = body
      Net::HTTP.new(uri.hostname, uri.port).start { |http| http.request(req) }
    end

    private

    def defaults
      { json: "#{Dir.pwd}/locatine_files/default.json", depth: 3, trusted: [],
        untrusted: [], tolerance: 50, stability: 10, timeout: 25 }
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

    def define_timeout(params)
      params['timeout'] = params['timeout']
                          .to_i - (Time.now - @start_time).round
      params
    end

    def find_routine(params, parent)
      results = Results.new
      params = define_timeout(params)
      answer = results.find(self, params, parent)
      if !answer.empty? && answer.first.class != Locatine::Error
        @elements[results.name] = results.info
        write
      end
      answer
    end

    def call_uri(path)
      URI::HTTP.build(
        host: @parsed_selenium.host,
        port: @parsed_selenium.port,
        path: "/wd/hub/session/#{@session}#{path}"
      )
    end
  end
end
