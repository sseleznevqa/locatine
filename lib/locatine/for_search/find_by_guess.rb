module Locatine
  module ForSearch
    ##
    # If html code is good and name is related to the code, Locatine can guess
    # it
    #
    # Methods for finding element by name only
    module FindByGuess
      private

      def main_guess(name)
        all = []
        name.split(' ').each do |part|
          all += guess_by_part(part)
        end
        all
      end

      def guess_by_part(part)
        all = []
        tag_xpath = "//#{part}#{not_magic_div}"
        text_xpath = "//*[contains(text(),'#{part}')]#{not_magic_div}"
        attr_xpath = "//*[@*[contains(., '#{part}')]]#{not_magic_div}"
        all += find_by_locator(xpath: tag_xpath).to_a
        all += find_by_locator(xpath: text_xpath).to_a
        all += find_by_locator(xpath: attr_xpath).to_a
        all
      end

      def full_guess(all, vars, name)
        max = all.count(all.max_by { |i| all.count(i) })
        if max >= name.split(' ').length
          guess = (all.select { |i| all.count(i) == max }).uniq
          guess_data = generate_data(guess, vars)
          found_by_data = find_by_data(guess_data, vars)
        end
        return found_by_data, guess_data.to_h
      end

      def check_guess(all, vars, name, scope)
        guess, guess_data = full_guess(all, vars, name)
        if guess.nil? || (engine.elements.length / guess.length <= 4)
          send_no_guess(name, scope)
          guess = nil
          guess_data = {}
        else
          send_has_guess(guess.length, name, scope)
        end
        return guess, guess_data
      end

      def find_by_guess(scope, name, vars)
        @cold_time = 0
        all = main_guess(name)
        if all.empty?
          send_no_guess(name, scope)
        else
          guess, guess_data = check_guess(all, vars, name, scope)
        end
        @cold_time = nil
        return guess, guess_data.to_h
      end
    end
  end
end
