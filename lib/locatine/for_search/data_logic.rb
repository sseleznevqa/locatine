module Locatine
  module ForSearch
    ##
    # Logic of collecting data of the element
    module DataLogic
      private

      def get_dynamic_attributes(data, vars)
        attrs = []
        data.each do |hash|
          hash.each_pair do |key, full_value|
            full_value.split(' ').each do |value|
              next if key != 'locatineclass'
              
              replace = vars[key.to_sym]
              attrs.push push_hash(key,
                         replace ? value.gsub(replace, "\#{#{key}}") : value,
                         'attribute')
            end
          end
        end
        attrs
      end

      def get_element_raw(element)
        element = element.wd.wd if element.tag_name == 'iframe'
        script = File.read("#{HOME}/large_scripts/element.js")
        engine.execute_script(script, element)
      end

      ##
      # Generating array of hashes representing data of the element
      def get_element_info(element, vars, depth)
        data = get_element_raw(element)
        attrs = get_dynamic_attributes(data['attrs'], vars)
        attrs.push get_dynamic_tag(data['tag'], vars)
        attrs += get_dynamic_text(data['text'], vars)
        attrs += get_dynamic_css(element, vars) if depth.to_i.zero? && visual?
        attrs.push get_dimensions(element) if depth.to_i.zero? && visual?
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

      def equal_elements?(one, another)
        good = true unless one == {}
        one.each_pair do |depth, array|
          trusted = get_trusted(array).map do |i|
            i.reject { |k| k == 'stability' }
          end
          good &&= ((trusted - another[depth] == []) && !trusted.empty?)
        end
        good
      end

      def find_in_data(attributes)
        found = []
        @data.each_pair do |scope, elements|
          elements.each_pair do |element, hash|
            good = equal_elements?(hash, attributes)
            found.push(scope: scope, name: element) if good
          end
        end
        found.empty? ? nil : found
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
    end
  end
end
