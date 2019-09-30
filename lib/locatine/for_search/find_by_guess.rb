module Locatine
  module ForSearch
    ##
    # If html code is good and name is related to the code, Locatine can guess
    # it
    #
    # Methods for finding element by name only
    module FindByGuess
      private

      def all_similar(name, page, vars)
        all = []
        array = generate_hash_array(name)
        array.each do |hash|
          all += catch(page, hash, vars, 0)
        end
        all
      end

      def all_suggested(all, name, scope)
        if all.empty?
          send_no_guess(name, scope)
          return nil
        end
        suggested = most_common_of(all).map do |element|
          engine.elements(tag_name: element['tag'])[element['index'].to_i]
        end
        suggested
      end

      def main_guess(name, scope, page, vars)
        all = all_similar(name, page, vars)
        all_suggested(all, name, scope)
      end

      def guessing(name, scope, page, vars)
        suggested = main_guess(name, scope, page, vars)
        suggest, attributes = final_of_all(suggested, vars) if suggested
        return suggest, attributes
      end

      def find_by_guess(scope, name, vars, iteration = 0)
        html = take_html
        page = take_dom
        suggest, attributes = guessing(name, scope, page, vars)
        if html != take_html && iteration < 5
          return find_by_guess(scope, name, vars, iteration + 1)
        end

        warn_highly_unstable if iteration == 5
        send_has_guess(name, scope) if suggest
        return suggest, attributes.to_h
      end

      def generate_hash_array(name)
        array = []
        name.split(' ').each do |part|
          array.push push_hash(part, '', 'attribute')
          array.push push_hash('', part, 'attribute')
          array.push push_hash('text', part, 'text')
          array.push push_hash('tag', part, 'tag')
        end
        array
      end
    end
  end
end
