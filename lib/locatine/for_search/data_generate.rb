module Locatine
  module ForSearch
    ##
    # Collecting data of element and making it dynamic
    module DataGenerate
      private

      def mesure(element)
        xy = element.location
        wh = element.size
        return xy.x, xy.y, wh.width, wh.height
      end

      def get_dynamic_tag(tag, vars)
        tag = "\#{tag}" if vars[:tag].to_s.casecmp(tag).zero?
        push_hash('tag', tag, 'tag')
      end

      def text_array(text)
        text.to_s.tr("\n", ' ').split(/['" ]/)
      end

      def get_dynamic_text(text, vars)
        attrs = text_array(text).map do |word|
          final = if !vars[:text].to_s.strip.empty?
                    word.gsub(vars[:text].to_s, "\#{text}")
                  else
                    word
                  end
          push_hash('text', final, 'text') unless final.empty?
        end
        attrs.compact
      end

      def get_dimensions(element)
        resolution = window_size
        x, y, w, h = mesure(element)
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
    end
  end
end
