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
        result = ''
        values = process_string(hash['value'], vars).split(/[,.-_ ;'\\"]/)
        values.each do |value|
          result += generate_real_xpath_part(hash, value) if !value.empty?
        end
        result
      end

      def generate_real_xpath_part(hash, value)
        case hash['type']
        when 'tag'
          "[self::#{value}]"
        when 'text'
          "[contains(text(), '#{value}')]"
        when 'attribute'
          "[contains(@#{hash['name']}, '#{value}')]"
        end
      end
    end
  end
end
