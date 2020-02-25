# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    #
    # Methods for active looking for element
    module FindByMagic
      def magic_thread
        Thread.new do
          while empty?
            magic_find
            clear unless similar?
          end
        end
      end

      def classic_thread
        Thread.new do
          while empty?
            sleep 0.5
            classic_find
          end
        end
      end

      def find_by_magic
        warn_magic
        classic = classic_thread
        magic = magic_thread
        sleep 0.1 while timer && !similar?
        classic.kill
        magic.kill
        normalize_indexes(magic['out']) if empty? && (magic['out'].to_h != {})
        self
      end

      def magic_routine(data)
        Thread.current['out'] = {}
        page = @session.page
        data.each_pair do |depth, array|
          get_trusted(array).each do |hash|
            Thread.current['temp'] = []
            catch(page, hash, depth)
            temp_results_push
          end
        end
      end

      def temp_results_push
        Thread.current['temp'].uniq.each do |index|
          thread_out[index] ||= 0
          thread_out[index] += 1
        end
      end

      def magic_find(data = known)
        magic_routine(data)
        normalize_indexes
      end

      def normalize_indexes(indexes = Thread.current['out'])
        all = { 'using' => 'tag name', 'value' => '*' }
        list = @session.api_request('/elements', 'Post', all.to_json).body
        list = JSON.parse(list)['value']
        answers = max_indexes(indexes).map { |index| list[index.to_i] }
        answers.each do |item|
          push Locatine::Element.new(@session, item)
        end
      end

      def max_indexes(indexes)
        max = 0
        array = []
        indexes.each_pair do |index, count|
          next if count < max

          array.push(index)
          next if count == max

          array = [index]
          max = count
        end
        array
      end

      def catch(page, hash, depth)
        page.each do |element|
          caught = (element['data'].select do |item|
                      info_hash_eq(item, hash)
                    end).first
          kids([element], depth) if caught
          catch(element['children'], hash, depth)
        end
      end

      def kids(array, depth)
        array.each do |element|
          Thread.current['temp'].push element['index']
          if !element['children'].empty? && depth.to_i.positive?
            kids(element['children'], depth)
          end
        end
      end

      def count_similarity
        all = 0
        same = 0
        # Next is necessary for unknown reason (smthing thread related)
        raw = raw_info['0']
        get_trusted(known['0']).each do |hash|
          caught = (raw.select { |item| info_hash_eq(item, hash) }).first
          all += 1
          same += 1 if caught
        end
        similar_enough(same, all)
      end

      def similar?
        return false if empty?

        return true if tolerance == 100

        count_similarity
      end

      def similar_enough(same, all)
        sameness = (same * 100) / all
        sameness >= 100 - tolerance
      end
    end
  end
end
