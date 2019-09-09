module Locatine
  module ForSearch
    ##
    # Logic for finding lost element
    module FindByMagic
      private

      ##
      # Getting all the elements via black magic
      def find_by_magic(name, scope, data, vars, iteration = 0)
        page = take_dom
        html = engine.html
        suggested = magic_elements(name, scope, data, vars, page)
        warn_unstable if html != engine.html || page != take_dom
        if html != engine.html and iteration < 5
          return find_by_magic(name, scope, data, vars, iteration + 1)
        end

        warn_highly_unstable if iteration == 5
        suggest_by_all(suggested, data, vars, name, scope)
      end

      ##
      # We are taking every element that look at least a bit similar to one we
      # are looking for
      def magic_elements(name, scope, data, vars, page)
        warn_element_lost(name, scope)
        all = select_from_page(page, data, vars)
        raise_not_found(name, scope) if all.empty? && !@current_no_f
        suggested = most_common_of(all).map do |element|
          engine.elements(tag_name: element['tag'])[element['index'].to_i]
        end
        suggested
      end

      def similar_enough(data, attributes)
        same = same_entries(data['0'], attributes, '0').length
        all = data['0'].length
        sameness = (same * 100) / all
        sameness >= 100 - @current_t
      end

      def final_of_all(suggest, vars)
        attributes = generate_data(suggest, vars) unless suggest.empty?
        return suggest, attributes
      end

      def suggest_by_all(all, data, vars, name, scope)
        suggest, attributes = final_of_all(all, vars)
        ok = similar_enough(data, attributes) unless suggest.empty?
        raise_not_similar(name, scope) if !ok && !@current_no_f
        if ok
          warn_lost_found(name, scope)
          return suggest, attributes
        end
        warn_not_found(name, scope)
        return nil, nil
      end
    end
  end
end
