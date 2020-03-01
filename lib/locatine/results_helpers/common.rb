# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    #
    # Some common methods without much logic
    module Common
      def timer
        @time ||= Time.now
        timeout > Time.now - @time
      end

      def name_only?
        @locator['value'].empty? && !known && @name
      end

      def known
        @session.elements[@name]
      end

      def unknown_no_text(item, hash)
        ((item['type'] == '*') && (hash['type'] != 'text')) ||
          ((item['type'] != 'text') && (hash['type'] == '*'))
      end

      def same_name_type(item, hash)
        (item['name'] == hash['name']) && (item['type'] == hash['type'])
      end

      def info_hash_eq(item, hash)
        # Return true
        # If type is unknown (but not a text)
        # Or when type and name are similar
        (unknown_no_text(item, hash) || same_name_type(item, hash)) &&
          # And at the same time values are (almost) the same
          (item['value'].downcase == hash['value'].downcase)
      end

      def stability
        @config['stability'] || @session.stability
      end

      def trusted
        @config['trusted'] || @session.trusted
      end

      def untrusted
        @config['untrusted'] || @session.untrusted
      end

      def tolerance
        @config['tolerance'] || @session.tolerance
      end

      def timeout
        @config['timeout'] || @session.timeout
      end

      def the_depth
        @config['depth'] || @session.depth
      end

      def thread_out
        Thread.current['out']
      end
    end
  end
end
