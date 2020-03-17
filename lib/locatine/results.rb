# frozen_string_literal: true

module Locatine
  ##
  # Locatine results container.
  #
  # Results is a pretty strange concept. It is an array of returned elements
  # which is extended by methods of finding and gathering elements.
  class Results < Array
    include Locatine::ResultsHelpers::InfoGenerator
    include Locatine::ResultsHelpers::XpathGenerator
    include Locatine::ResultsHelpers::FindByMagic
    include Locatine::ResultsHelpers::Common
    include Locatine::Logger
    include Locatine::ResultsHelpers::Guess
    include Locatine::ResultsHelpers::Comparing
    include Locatine::ResultsHelpers::Config

    attr_accessor :name

    ##
    # Method to find elements
    #
    # @param session [Locatine::Session]
    # @param locator [Hash] can be a classic locator shaped for webdriver
    #   protocol like:
    #
    #   +{'using => 'xpath', 'value' => '//div'}+ or
    #   +{'using' => 'css selector', 'value' => 'div'}+
    #
    #   It also can be a locator with magic comment like:
    #
    #   +{'using' => 'css selector', 'value' => 'div/*magic comment*/'}+
    #
    #   It also can be a locator with incapsulated json
    #
    #   +{'using' => 'css selector', 'value' => 'div/*{"name": "magic "}*/'}+
    #
    #   It can be a locatine locator
    #
    #   +{'using' => 'locatine', 'value' => '{"name": "magic comment"}'}+ or
    #   +{'using' => 'locatine', 'value' => 'magic comment'}+
    # @param parent is the parent element to look for the nested ones.
    # @return class instance populated by results or an empty array
    def find(session, locator, parent)
      configure(session, locator, parent)
      find_routine
      return self unless empty?

      find_by_magic if known && tolerance.positive?
      similar? ? found : not_found
    end

    ##
    # Method to return information about elements found
    #
    # Information is returned combined with the previously known data and can
    # be stored and used as is. It means that its returning not the data about
    # one particular search. But the combined data of all previous searches
    def info
      stability_bump(raw_info)
    end

    private

    def find_routine
      timer
      classic_find
      guess if name_only?
      return if first.class == Locatine::Error || empty?

      check_guess if name_only?
    end

    def check_guess
      map(&:tag_name).uniq.size == 1 ? log_found : clear
    end

    def simple_find
      path = @parent ? "/element/#{@parent}/elements" : '/elements'
      response = @session.api_request(path, 'Post', @locator.to_json)
      found = JSON.parse(response.body)
      error_present = (found['value'].class == Hash) && found['value']['error']
      return error_routine(response) if error_present

      found['value'].each do |item|
        push Locatine::Element.new(@session, item)
      end
      self
      #   {"value"=>
      #  [{"element-6066-11e4-a52e-4f735466cecf"=>"c95a0580-4ac7-4c6d-..."},
      #  {"element-6066-11e4-a52e-4f735466cecf"=>"f419f6cf-1a04-4bc8-b246-..."},
      #  {"element-6066-11e4
    end

    def error_routine(answer)
      @error = Locatine::Error.new(answer)
      warn_error_detected(answer)
      push @error
    end

    def classic_find
      first_attempt
      locating = (@locator['value'].empty? || tolerance.positive?) && !@error
      return unless locating

      second_attempt
      third_attempt if known
      forth_attempt if known
    end

    def first_attempt
      log_start
      simple_find unless @locator['value'].empty?
      warn_locator if !@locator['value'].empty? && empty?
    end

    def third_attempt
      base = {}
      base['0'] = known['0']
      find_by_data(base) if empty?
    end

    def second_attempt
      find_by_data if known && empty?
    end

    def forth_attempt
      base = {}
      base['0'] = known['0'].select { |item| trusted.include?(item['name']) }
      find_by_data(base) if empty? && !trusted.empty? && !base['0'].empty?
    end

    def found
      log_found
      uniq
    end

    def not_found
      warn_lost
      []
    end
  end
end
