module Locatine
  module ForSearch
    ##
    # Looking for elements by css values
    module FindByCss
      private

      def css_array_by_data(data, vars)
        q_css = []
        get_trusted(data['0']).each do |hash|
          if hash['type'] == 'css'
            value = process_string(hash['value'], vars) if vars[hash['name']]
            q_css.push("#{hash['name']}: #{value || hash['value']}")
          end
        end
        q_css
      end

      def return_caught_elements(caught)
        all = []
        caught.each do |i|
          @help_hash[i[0]] ||= engine.elements(tag_name: i[0].downcase).to_a
          elm = @help_hash[i[0]][i[1].to_i]
          all.push(elm) if elm
        end
        all
      end

      def select_elements_from_raws_by_css(q_css, raws)
        all = []
        @help_hash = {}
        q_css.each do |item|
          caught = (raws.select { |i| i[2].include?(item) })
          all += return_caught_elements(caught)
        end
        all
      end

      def full_find_by_css(data, vars)
        q_css = css_array_by_data(data, vars)
        script = File.read("#{HOME}/large_scripts/css.js")
        raws = engine.execute_script(script)
        select_elements_from_raws_by_css(q_css, raws)
      end
    end
  end
end
