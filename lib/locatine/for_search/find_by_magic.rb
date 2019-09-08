module Locatine
  module ForSearch
    ##
    # Logic for finding lost element
    module FindByMagic
      private

      ##
      # Getting all the elements via black magic
      def find_by_magic(name, scope, data, vars)
        warn_element_lost(name, scope)
        page = take_dom
        all = select_from_page(page, data, vars)
        raise_not_found(name, scope) if all.empty? && !@current_no_f
        suggested = []
        most_common_of(all).each do |element|
          suggested.push engine.elements(tag_name: element['tag'])[element['index'].to_i]
        end

        return suggest_by_all(suggested, data, vars, name, scope) if page == take_dom

        find_by_magic(name, scope, data, vars)
      end

      def most_common_of(all)
        max = all.count(all.max_by { |i| all.count(i) })
        return (all.select { |i| all.count(i) == max }).uniq unless max.zero?

        []
      end

      def take_dom
        script = File.read("#{HOME}/large_scripts/page.js")
        engine.execute_script(script)
      end

      def select_from_page(page, data, vars)
        all = [] # No result is a valid result too
        data.each_pair do |depth, array|
          get_trusted(array).each do |hash|
            all += catch(page, hash, vars, depth)
          end
        end
        all
      end

      def catch(page, hash, vars, depth)
        all = []
        hash['value'] = process_string(hash['value'], vars)
        page.each do |element|
          all += take_match(element, depth, hash, vars)
          all += catch(element['children'], hash, vars, depth)
        end
        all
      end

      def take_match(element, depth, hash, vars)
        case hash['type']
        when 'tag'
          take_by_tag(hash, element, depth)
        when 'text'
          take_by_text(hash, element, depth)
        when 'attribute'
          take_by_attribute(hash, element, depth)
        when 'dimensions'
          take_by_dimensions(hash, element, depth, vars)
        when 'css'
          take_by_css(hash, element, depth)
        end
      end

      def take_by_tag(hash, elt, depth)
        return kids([elt], depth) if elt['tag'].downcase.include?(hash['value'])

        []
      end

      def take_by_text(hash, elt, depth)
        return kids([elt], depth) if elt['text'].include?(hash['value'])

        []
      end

      def take_by_attribute(hash, elt, depth)
        check = elt['attrs'][hash['name']].to_s
        return kids([elt], depth) if check.include?(hash['value'])

        []
      end

      def dimensions_for_search(hash, vars)
        values = hash['value'].split('*').map { |item| item.to_i };
        values[0] = vars[:x].to_i if vars[:x]
        values[1] = vars[:y].to_i if vars[:y]
        values
      end

      def take_by_dimensions(hash, elt, depth, vars)
        return [] unless visual?

        return [] unless hash['name'] == window_size

        values = dimensions_for_search(hash, vars)
        top = elt['coordinates']['top'].to_i
        bottom = elt['coordinates']['bottom'].to_i
        left = elt['coordinates']['left'].to_i
        right = elt['coordinates']['right'].to_i
        x_check = (values[0].to_i >= left) && (values[0] + values[2] <= right)
        y_check = (values[1].to_i >= top) && (values[1] + values[3] <= bottom)
        return kids([elt], depth) if (x_check && y_check)

        []
      end

      def take_by_css(hash, elt, depth)
        return [] unless visual?

        string = "#{hash['name']}: #{hash['value']}"
        return kids([elt], depth) if elt['style'].include?(string)

        []
      end

      # If depth != 0 we should return all children subchildren.
      def kids(array, depth)
        answer = []
        return array if depth.to_i == 0

        array.each do |one|
          answer += one['children']
          answer += kids(one['children'], depth)
        end
        answer
      end

      def similar_enough(data, attributes)
        same = same_entries(data['0'], attributes, '0').length
        all = data['0'].length
        sameness = (same * 100) / all
        sameness >= 100 - @current_t
      end

      def best_of_all(suggest, vars)
        attributes = generate_data(suggest, vars) unless suggest.empty?
        return suggest, attributes
      end

      def suggest_by_all(all, data, vars, name, scope)
        suggest, attributes = best_of_all(all, vars)
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
