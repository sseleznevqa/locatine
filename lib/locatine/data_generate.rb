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
      { 'name' => 'tag', 'value' => tag, 'type' => 'tag' }
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
        attrs.push('name' => 'text', 'value' => final_word, 'type' => 'text')
      end
      attrs
    end

    ##
    # Generating array of hashes representing data of the element
    def get_element_info(element, vars, depth)
      attrs = get_dynamic_attributes(element, vars)
      attrs.push get_dynamic_tag(element, vars)
      attrs += get_dynamic_text(element, vars)
      attrs += get_dynamic_css(element, vars) if depth.to_i == 0
      attrs
    end

    def hash_by_style(style, value, vars)
      value.gsub!(vars[style.to_sym], "\#{#{style}}") if vars[style.to_sym]
      { 'name' => style, 'value' => value, 'type' => 'css' }
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
      current_depth = 0
      attributes = {}
      while current_depth != @depth
        attributes[current_depth.to_s] =
                               get_element_info(element, vars, current_depth)
        current_depth += 1
        element = element.parent
        current_depth = @depth unless element.exists?
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
