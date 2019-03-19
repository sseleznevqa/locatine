module Locatine
  ##
  # Generating locatine json info from element itself
  module DataGenerate
    private

    def get_dynamic_attributes(element, vars)
      attrs = []
      get_attributes(element).each do |hash|
        if vars[hash['name'].to_sym]
          hash['value'].gsub!(vars[hash['name'].to_sym], "\#{#{hash['name']}}")
        end
        attrs.push hash
      end
      attrs
    end

    def get_dynamic_tag(element, vars)
      tag = element.tag_name
      tag = "\#{tag}" if vars[:tag] == tag
      push_hash('tag', tag, 'tag')
    end

    def real_text_of(element)
      element.text == element.inner_html ? element.text : ''
    end

    def get_dynamic_text(element, vars)
      attrs = []
      real_text_of(element).split(' ').each do |word|
        final_word = if !vars[:text].to_s.strip.empty?
                       word.gsub(vars[:text].to_s, "\#{text}")
                     else
                       word
                     end
        attrs.push push_hash('text', final_word, 'text')
      end
      attrs
    end

    ##
    # Generating array of hashes representing data of the element
    def get_element_info(element, vars, depth)
      attrs = get_dynamic_attributes(element, vars)
      attrs.push get_dynamic_tag(element, vars)
      attrs += get_dynamic_text(element, vars)
      attrs += get_dynamic_css(element, vars) if depth.to_i.zero?
      attrs.push get_dimensions(element, vars) if depth.to_i.zero?
      attrs
    end

    def mesure(element)
      b_w, b_h = window_size
      xy = element.location
      wh = element.size
      return b_w, b_h, xy.x, xy.y, wh.width, wh.height
    end

    def processed_dimensions(element, vars)
      b_w, b_h, x, y, width, height = mesure(element)
      x = x.to_s.gsub(vars[:x], "\#{#{x}}") if vars[:x]
      y = y.to_s.gsub(vars[:y], "\#{#{y}}") if vars[:y]
      width = width.to_s.gsub(vars[:width], "\#{#{width}}") if vars[:width]
      height = height.to_s.gsub(vars[:height], "\#{#{height}}") if vars[:height]
      return b_w, b_h, x, y, width, height
    end

    def get_dimensions(element, vars)
      b_w, b_h, x, y, w, h = processed_dimensions(element, vars)
      push_hash("#{b_w}x#{b_h}", "#{x}x#{y}x#{w}x#{h}", 'dimensions')
    end

    def hash_by_style(style, value, vars)
      value.gsub!(vars[style.to_sym], "\#{#{style}}") if vars[style.to_sym]
      push_hash(style, value, 'css')
    end

    def get_raw_css(element)
      test_script = 'return typeof(arguments[0])'
      ok = engine.execute_script(test_script, element) == 'object'
      script = 'return getComputedStyle(arguments[0]).cssText'
      return engine.execute_script(script, element) if ok
    end

    def get_dynamic_css(element, vars)
      attrs = []
      raw = get_raw_css(element)
      if raw
        styles = css_text_to_hash(get_raw_css(element))
        (styles.to_a - @default_styles).to_h.each_pair do |style, value|
          hash = hash_by_style(style, value, vars)
          attrs.push(hash) if hash
        end
      end
      attrs
    end

    ##
    # Generating data for group of elements
    def generate_data(result, vars)
      family = {}
      result.each do |item|
        family = get_commons(get_family_info(item, vars), family)
      end
      family
    end

    ##
    # Getting element\\parents information
    def get_family_info(element, vars)
      i = 0
      attributes = {}
      while i != @depth
        attributes[i.to_s] = get_element_info(element, vars, i)
        i += 1
        element = element.parent
        i = @depth unless element.exists?
      end
      attributes
    end

    ##
    # Collecting attributes of the element
    def get_attributes(element)
      attributes = element.attributes
      array = []
      attributes.each_pair do |name, value|
        next if name.to_s == 'locatineclass'

        value.split(' ').uniq.each do |part|
          array.push('name' => name.to_s, 'type' => 'attribute',
                     'value' => part)
        end
      end
      array
    end
  end
end
