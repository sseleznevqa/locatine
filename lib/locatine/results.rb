# frozen_string_literal: true

require 'locatine/results_helpers/info_generator'
require 'locatine/results_helpers/xpath_generator'
require 'locatine/results_helpers/find_by_magic'
require 'locatine/results_helpers/common'
require 'locatine/results_helpers/logger'
require 'locatine/results_helpers/guess'

module Locatine
  #
  # Locatine results container
  class Results < Array
    include Locatine::ResultsHelpers::InfoGenerator
    include Locatine::ResultsHelpers::XpathGenerator
    include Locatine::ResultsHelpers::FindByMagic
    include Locatine::ResultsHelpers::Common
    include Locatine::ResultsHelpers::Logger
    include Locatine::ResultsHelpers::Guess

    attr_accessor :name, :config, :locator

    def configure(session, locator, parent)
      @session = session
      @locator = locator.clone
      read_locator
      @parent = parent
    end

    def simple_find
      path = @parent ? "/element/#{@parent}/elements" : '/elements'
      selenium_found = @session.api_request(path, 'Post', @locator.to_json).body
      JSON.parse(selenium_found)['value'].each do |item|
        push Locatine::Element.new(@session, item)
      end
      self
      #   {"value"=>
      #  [{"element-6066-11e4-a52e-4f735466cecf"=>"c95a0580-4ac7-4c6d-..."},
      #  {"element-6066-11e4-a52e-4f735466cecf"=>"f419f6cf-1a04-4bc8-b246-..."},
      #  {"element-6066-11e4
    end

    def classic_find
      first_attempt
      locating = @locator['value'].empty? || tolerance.positive?
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

    def find
      timer
      classic_find
      guess if name_only?
      return self unless empty?

      find_by_magic if known && tolerance.positive?
      similar? ? found : not_found
    end

    def found
      log_found
      uniq
    end

    def not_found
      warn_lost
      []
    end

    def read_locator
      case @locator['using']
      when 'css selector'
        # "button/*{json}*/"
        read_locator_routine(%r{/\*(.*)\*/$})
      when 'xpath'
        # "//button['{json}']"
        read_locator_routine(/\[\'(.*)\'\]$/)
      when 'locatine'
        read_locator_routine(/(.*)/)
      end
    end

    def read_locator_routine(regexp)
      matched = @locator['value'].match(regexp)
      @config = matched ? config_provided(matched[1]) : {}
      @locator['value'] = @locator['value'].gsub(matched[0], '') if matched
      @locator = @config['locator'] if @config['locator']
      @name = @config['name'] || @locator['value']
    end

    def config_provided(config)
      JSON.parse(config)
    rescue StandardError
      result = {}
      result['tolerance'] = 0 if config.start_with?('exactly')
      result['name'] = config.gsub('exactly ', '')
      result
    end
  end
end
