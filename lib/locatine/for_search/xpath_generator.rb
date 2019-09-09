module Locatine
  module ForSearch
    ##
    # Methods for generation xpath from stored data
    module XpathGenerator
      private

      def get_trusted(array)
        if !array.empty?
          max = max_stability(array)
          (array.select { |i| i['stability'].to_i == max.to_i }).uniq
        else
          []
        end
      end

      def max_stability(array)
        max = (array.max_by { |i| i['stability'].to_i }) if array
        return max['stability'] if max

        0
      end

      def generate_xpath(data, vars)
        xpath = "[not(@id = 'locatine_magic_div')]"
        data.each_pair do |_depth, array|
          get_trusted(array).each do |hash|
            xpath = generate_xpath_part(hash, vars).to_s + xpath
          end
          xpath = '/*' + xpath
        end
        xpath = '/' + xpath
        xpath
      end

      def generate_xpath_part(hash, vars)
        value = process_string(hash['value'], vars)
        case hash['type']
        when 'tag'
          "[self::#{value}]"
        when 'text'
          "[contains(text(), '#{value}')]"
        when 'attribute'
          generate_xpath_part_from_attribute(hash, value)
        end
      end

      def generate_xpath_part_from_attribute(hash, value)
        full = '[@*'
        hash['name'].split('_')
                    .each { |part| full += "[contains(name(), '#{part}')]" }
        full + "[contains(., '#{value}')]]"
      end
    end
  end
end
