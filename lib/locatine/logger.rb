# frozen_string_literal: true

require 'colorize'

module Locatine
  #
  # Methods for sending lines to STDOUT
  module Logger
    def warn(text)
      puts "WARNING: #{Time.now}: ".yellow + text
    end

    def log(text)
      puts "MESSAGE: #{Time.now}: ".magenta + text
    end

    def locatine_error(text)
      puts "ERROR: #{Time.now}: ".red + text.red
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

    def warn_unstable_page
      warn 'Locatine detected stale element error. It means some elements'\
           ' found by locatine are not attached to DOM anymore.'\
           ' Page is unstable. Starting searching process again'
    end

    def log_found
      log "Locatine found something as #{@name}"
      log "XPATH == #{generate_xpath(raw_info)}"
    end

    def raise_script_error(script, args, answer)
      locatine_error 'Locatine faced an error while trying to perform '\
        "js script.\n ---Script was: #{script}\n\n ---Arguments was: #{args}"\
        "\n\n ---Answer was: #{answer}"
      raise answer['error']
    end

    def warn_error_detected(answer)
      warn "selenium is returning an error with code #{answer.code} "\
           'It will be returned to your code. It can be locatine internal '\
           'bug, selenium problem (dead browser for example) or something '\
           'in your code (invalid locator for example)'
    end
  end
end
