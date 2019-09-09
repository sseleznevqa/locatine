module Locatine
  module ForSearch
    ##
    # Methods about getting full information about opened page>
    # And methods for stalkibg around the page in oreder to find something.
    module PageWork
      private

      def matcher
        { 'tag' => ->(data) { take_by_tag(*data) },
          'text' => ->(data) { take_by_text(*data) },
          'attribute' => ->(data) { take_by_attribute(*data) },
          'css' => ->(data) { take_by_css(*data) } }
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
        all.uniq
      end

      def take_match(element, depth, hash, vars)
        if hash['type'] == 'dimensions'
          return take_by_dimensions(hash, element, depth, vars)
        end

        matcher.fetch(hash['type']).call([hash, element, depth])
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
        values = hash['value'].split('*').map(&:to_i)
        values[0] = vars[:x].to_i if vars[:x]
        values[1] = vars[:y].to_i if vars[:y]
        values
      end

      def dimensions_from_page(elt)
        [elt['coordinates']['top'].to_i, elt['coordinates']['bottom'].to_i,
         elt['coordinates']['left'].to_i, elt['coordinates']['right'].to_i]
      end

      def take_by_dimensions(hash, elt, depth, vars)
        return [] if !visual? || hash['name'] != window_size

        return kids([elt], depth) if in_recatngle?(hash, elt, vars)

        []
      end

      def in_recatngle?(hash, elt, vars)
        cleft, ctop, cwidth, cheight = dimensions_for_search(hash, vars)
        top, bottom, left, right = dimensions_from_page(elt)
        (cleft >= left) && (cleft + cwidth <= right) &&
          (ctop >= top) && (ctop + cheight <= bottom)
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
        return array if depth.to_i.zero?

        array.each do |one|
          answer += one['children']
          answer += kids(one['children'], depth)
        end
        answer
      end
    end
  end
end
