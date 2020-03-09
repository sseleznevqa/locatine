# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    ##
    # Methods for generation xpath from stored data
    module XpathGenerator
      private

      def find_by_data(base = known)
        xpath = generate_xpath(base)
        @locator = { 'using' => 'xpath', 'value' => xpath }
        simple_find
      end

      def get_trusted(array)
        if !array.empty?
          max = max_stability(array)
          (array.select do |i|
            (i['stability'].to_i == max.to_i) && !untrusted.include?(i['name'])
          end).uniq
        else
          []
        end
      end

      def max_stability(array)
        max = (array.max_by { |i| i['stability'].to_i }) if array
        return max['stability'] if max

        0
      end

      def generate_xpath(data)
        xpath = ''
        data.each_pair do |_depth, array|
          get_trusted(array).each do |hash|
            xpath = generate_xpath_part(hash).to_s + xpath
          end
          xpath = '/*' + xpath
        end
        xpath = '/' + xpath
        xpath
      end

      def generate_xpath_part(hash)
        case hash['type']
        when 'tag'
          "[self::#{hash['value']}]"
        when 'text'
          "[contains(text(), '#{hash['value']}')]"
        when 'attribute'
          "[contains(@#{hash['name']}, '#{hash['value']}')]"
        end
      end
    end
  end
end
