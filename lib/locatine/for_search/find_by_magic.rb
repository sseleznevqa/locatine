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
        @cold_time = 0
        all = all_options(data, vars)
        @cold_time = nil
        raise_not_found(name, scope) if all.empty? && !@current_no_f
        suggest_by_all(all, data, vars, name, scope)
      end

      def similar_enough(data, attributes)
        same = same_entries(data['0'], attributes, '0').length
        all = data['0'].length
        sameness = (same * 100) / all
        sameness >= 100 - @current_t
      end

      def best_of_all(all, vars)
        max = all.count(all.max_by { |i| all.count(i) })
        suggest = (all.select { |i| all.count(i) == max }).uniq unless max.zero?
        attributes = generate_data(suggest, vars) unless suggest.nil?
        return suggest, attributes
      end

      def suggest_by_all(all, data, vars, name, scope)
        suggest, attributes = best_of_all(all, vars)
        ok = similar_enough(data, attributes) unless suggest.nil?
        raise_not_similar(name, scope) if !ok && !@current_no_f
        if ok
          warn_lost_found(name, scope)
          return suggest, attributes
        end
        warn_not_found(name, scope)
        return nil, nil
      end

      def all_options(data, vars)
        all = []
        data.each_pair do |depth, array|
          get_trusted(array).each do |hash|
            all += one_option_array(hash, vars, depth).to_a
          end
        end
        all += full_find_by_css(data, vars) if visual?
        all += find_by_dimensions(data, vars) if visual?
        all
      end

      def min_max_by_size(middle, size)
        min = middle - (size.to_i * (200 - @current_t)) / 200
        max = middle + (size.to_i * (200 - @current_t)) / 200
        return min, max
      end

      def middle(sizes)
        x = sizes[0].to_i + (sizes[2].to_i / 2)
        y = sizes[1].to_i + (sizes[3].to_i / 2)
        return x, y
      end

      def dimension_search_field(sizes)
        x, y = middle(sizes)
        x_min, x_max = min_max_by_size(x, sizes[2])
        y_min, y_max = min_max_by_size(y, sizes[3])
        return x_min, x_max, y_min, y_max
      end

      def retrieve_mesures(data)
        size = window_size
        dimensions = data['0'].map do |i|
          i if (i['type'] == 'dimensions') && (i['name'] == size)
        end
        dimensions.compact
      end

      def sizez_from_dimensions(dimensions, vars)
        result = []
        dimensions.first['value'].split('*').each do |value|
          result.push(process_string(value, vars))
        end
        result
      end

      def find_by_dimensions(data, vars)
        dimensions = retrieve_mesures(data)
        if !dimensions.empty?
          sizes = sizez_from_dimensions(dimensions, vars)
          xmi, xma, ymi, yma = dimension_search_field(sizes)
          script = File.read("#{HOME}/large_scripts/dimensions.js")
          engine.execute_script(script, xmi, xma, ymi, yma).compact
        else
          []
        end
      end

      def one_option_array(hash, vars, depth)
        case hash['type']
        when 'tag'
          find_by_tag(hash, vars, depth)
        when 'text'
          find_by_text(hash, vars, depth)
        when 'attribute'
          find_by_attribute(hash, vars, depth)
        end
      end
    end
  end
end
