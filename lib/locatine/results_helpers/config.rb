# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    #
    # Trying to configure results here
    module Config
      private

      def configure(session, locator, parent)
        @session = session
        @locator = locator.clone
        read_locator
        @parent = parent
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
end
