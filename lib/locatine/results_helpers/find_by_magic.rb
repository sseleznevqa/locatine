# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    ##
    # Methods for active looking for element
    module FindByMagic
      private

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
            classic_find
            sleep 1
          end
        end
      end

      def find_by_magic
        warn_magic
        classic = classic_thread
        magic = magic_thread
        sleep 0.1 while timer && !similar?
        kill_join(classic)
        kill_join(magic)
        normalize_indexes(magic['out']) if empty? && (magic['out'].to_h != {})
        self
      end

      def kill_join(thread)
        thread.kill
        thread.join
      end

      def magic_routine(data)
        Thread.current['out'] = {}
        page = @session.page
        data.each_pair do |depth, array|
          get_trusted(array).each do |hash|
            @temp = []
            catch(page, hash, depth)
            temp_results_push
          end
        end
      end

      def temp_results_push
        @temp.uniq.each do |index|
          thread_out[index] ||= 0
          thread_out[index] += 1
        end
      end

      def magic_find(data = known)
        @everything = all_elements
        magic_routine(data)
        normalize_indexes
      end

      def all_elements
        all = { 'using' => 'tag name', 'value' => '*' }
        list = @session.api_request('/elements', 'Post', all.to_json).body
        JSON.parse(list)['value']
      end

      def normalize_indexes(indexes = Thread.current['out'])
        list = all_elements
        warn_unstable_page if list != @everything
        max_list = max_indexes(indexes)
        old_answers = max_list.map { |index| @everything[index.to_i] }
        answers = max_list.map { |index| list[index.to_i] }
        return if old_answers != answers

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
          @temp.push element['index']
          if !element['children'].empty? && depth.to_i.positive?
            kids(element['children'], depth)
          end
        end
      end
    end
  end
end
