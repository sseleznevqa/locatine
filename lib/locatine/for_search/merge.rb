module Locatine
  module ForSearch
    ##
    # Getting commons of two piles of elements data. To find all similar to them
    module Merge
      private

      def select_same(where, hash)
        where.select do |item|
          (item['name'] == hash['name']) &&
            (item['value'] == hash['value']) &&
            (item['type'] == hash['type'])
        end
      end

      def same_entries(array, second, depth, stability_up = false)
        result = []
        array.each do |hash|
          to_add = select_same(second[depth], hash)
          to_add = stability_bump(to_add, hash) if stability_up
          result += to_add
        end
        result
      end

      ##
      # Merging data of two elements (new data is to find both)
      def get_commons(first, second)
        second = first if second == {}
        final = Hash.new { |hash, key| hash[key] = [] }
        first.each_pair do |depth, array|
          final[depth] = same_entries(array, second, depth)
        end
        final
      end
    end
  end
end
