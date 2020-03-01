# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    #
    # Methods for gathering element info
    module InfoGenerator
      def info
        stability_bump(raw_info)
      end

      def raw_info
        result = {}
        i = 0
        while i <= the_depth
          all = parents(i)
          data = all.map(&:info)
          result[i.to_s] = common_info(data) unless data.empty?
          i += 1
        end
        result
      end

      def parents(depth)
        all = clone
        depth.times do
          all.map!(&:parent)
          all.compact!
        end
        all
      end

      def catching_old_equal(hash, depth)
        if known && known[depth]
          old = known[depth].clone
          catched = (old.select { |item| info_hash_eq(item, hash) }).first
        end
        catched ||= hash
        catched
      end

      def hash_stability_bump(catched, max)
        new_stability = catched['stability'].to_i + 1
        max += 1 if max < stability
        catched['stability'] = new_stability if new_stability <= stability
        catched['stability'] = max if trusted.include?(catched['name'])
        catched['stability'] = 0 if untrusted.include?(catched['name'])
        catched
      end

      def stability_bump(data)
        result = {}
        data.each_pair do |depth, info_array|
          result[depth] = []
          max = max_stability(known.to_h[depth])
          info_array.each do |hash|
            catched = catching_old_equal(hash, depth)
            result[depth].push hash_stability_bump(catched, max)
          end
        end
        result
      end

      def common_info(elements_data)
        merged = elements_data.first
        elements_data.each do |element_data|
          merged = info_sum(merged, element_data)
        end
        merged
      end

      def info_sum(one, two)
        (one.map do |hash|
           (two.select { |item| info_hash_eq(item, hash) }).first
         end).compact
      end
    end
  end
end
