module Locatine
  ##
  # Logic for finding lost element
  module FindByMagic
    private

    ##
    # Getting all the elements via black magic
    def find_by_magic(name, scope, data, vars)
      warn "#{name} in #{scope} is lost. Looking for it."
      @cold_time = 0
      all = all_options(data, vars)
      @cold_time = nil
      raise "Unable to find element #{name} in #{scope}" if all.empty?

      suggest_by_all(all, data, vars, name, scope)
    end

    def similar_enough(data, attributes)
      (same_entries(data['0'], attributes, '0').length * 100 /
      data['0'].length) >= @tolerance
    end

    def suggest_by_all(all, data, vars, name, scope)
      max = all.count(all.max_by { |i| all.count(i) })
      suggestion = (all.select { |i| all.count(i) == max }).uniq
      attributes = generate_data(suggestion, vars)
      ok = similar_enough(data, attributes)
      raise "Unable to find element similar to #{name} in #{scope}" unless ok

      return suggestion, attributes
    end

    def all_options(data, vars)
      all = []
      data.each_pair do |depth, array|
        get_trusted(array).each do |hash|
          all += one_option_array(hash, vars, depth).to_a
        end
      end
      all += full_find_by_css(data, vars)
      all += find_by_dimensions(data, vars)
      all
    end

    def min_max_by_size(middle, size)
      min = middle - (size.to_i * (100 + @tolerance)) / 200
      max = middle + (size.to_i * (100 + @tolerance)) / 200
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
