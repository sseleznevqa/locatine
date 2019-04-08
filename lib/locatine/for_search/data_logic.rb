module Locatine
  module ForSearch
    ##
    # Logic of collecting data of the element
    module DataLogic
      private

      def get_dynamic_attributes(element, vars)
        attrs = []
        get_attributes(element).each do |hash|
          value = vars[hash['name'].to_sym]
          hash['value'].gsub!(value, "\#{#{hash['name']}}") if value
          attrs.push hash
        end
        attrs
      end

      ##
      # Generating array of hashes representing data of the element
      def get_element_info(element, vars, depth)
        attrs = get_dynamic_attributes(element, vars)
        attrs.push get_dynamic_tag(element, vars)
        attrs += get_dynamic_text(element, vars)
        attrs += get_dynamic_css(element, vars) if depth.to_i.zero? && visual?
        attrs.push get_dimensions(element, vars) if depth.to_i.zero? && visual?
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
