module Locatine
  ##
  # Collecting data of element and making it dynamic
  module DataGenerate
    private

    def real_text_of(element)
      element.text == element.inner_html ? element.text : ''
    end

    def mesure(element)
      xy = element.location
      wh = element.size
      return xy.x, xy.y, wh.width, wh.height
    end

    def get_dynamic_tag(element, vars)
      tag = element.tag_name
      tag = "\#{tag}" if vars[:tag] == tag
      push_hash('tag', tag, 'tag')
    end

    def get_dynamic_text(element, vars)
      attrs = []
      real_text_of(element).split(/['" ]/).each do |word|
        final = if !vars[:text].to_s.strip.empty?
                  word.gsub(vars[:text].to_s, "\#{text}")
                else
                  word
                end
        attrs.push push_hash('text', final, 'text') unless final.empty?
      end
      attrs
    end

    def process_dimension(name, value, vars)
      s_name = name.to_s
      value = value.to_s.gsub(vars[name], "\#{#{s_name}}") if vars[name]
      value
    end

    def processed_dimensions(element, vars)
      x, y, width, height = mesure(element)
      x = process_dimension(:x, x, vars)
      y = process_dimension(:y, y, vars)
      width = process_dimension(:width, width, vars)
      height = process_dimension(:height, height, vars)
      return x, y, width, height
    end

    def get_dimensions(element, vars)
      resolution = window_size
      x, y, w, h = processed_dimensions(element, vars)
      push_hash(resolution, "#{x}*#{y}*#{w}*#{h}", 'dimensions')
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
    # Collecting attributes of the element
    def get_attributes(element)
      attributes = element.attributes
      array = []
      attributes.each_pair do |name, value|
        next if name.to_s == 'locatineclass'

        value.split(/['" ]/).uniq.each do |part|
          array.push('name' => name.to_s, 'type' => 'attribute',
                     'value' => part) unless part.empty?
        end
      end
      array
    end
  end
end
