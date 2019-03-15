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
      data['0'].length) > @tolerance
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
          all += one_option_array(hash, vars, depth)
        end
      end
      all += full_find_by_css(data, vars)
      all
    end

    def full_find_by_css(data, vars)
      #making q_css hash
      q_css = []
      get_trusted(data['0']).each do |hash|
        if hash['type'] == 'css'
          q_css.push("#{hash['name']}: #{hash['value']}")
        end
      end

      # getting raw css of all els in b rowser
      raws = []
      engine.elements.each do |el|
        if el.exists?
          raws.push({el: el, css: get_raw_css(el).to_s})
        end
      end

      # Finally
      all = []
      q_css.each do |item|
        caught = (raws.select {|i| i[:css].include?(item)})
        all += caught.map {|i| i[:el]}
      end
      all
    end

    def one_option_array(hash, vars, depth)
      case hash['type']
      when 'tag'
        find_by_tag(hash, vars, depth).to_a
      when 'text'
        find_by_text(hash, vars, depth).to_a
      when 'attribute'
        find_by_attribute(hash, vars, depth).to_a
      when 'css'
        []
      end
    end
  end
end
