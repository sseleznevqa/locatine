# frozen_string_literal: true

require 'colorize'

module Locatine
  module ResultsHelpers
    #
    # Methods for sending lines to STDOUT
    module Logger
      def warn(text)
        puts "WARNING: #{Time.now}: ".yellow + text
      end

      def log(text)
        puts "MESSAGE: #{Time.now}: ".magenta + text
      end

      def warn_locator
        warn("Locator is broken. For #{name} by"\
             " #{@locator['using']}>>>'#{locator['value']}'")
      end

      def warn_guess
        warn("Locatine is trying to guess what is #{@name}")
      end

      def log_start
        log "#{Time.now}: Locatine is working on #{@name}"
      end

      def warn_magic
        warn "Locatine cannot find element #{@name} by usual methods and "\
             'starting to look for some element that is similar. Retrived '\
             'element may be not the one that is desired from this point'
      end

      def warn_lost
        warn "Locatine found nothing for #{@name}"
      end

      def log_found
        log "Locatine found something as #{@name}"
        log "XPATH == #{generate_xpath(raw_info)}"
      end
    end
  end
end
