module Locatine
  module ForSearch
    ##
    # We have a module that helps name elements
    module NameHelper
      private

      def good_name(main, vars)
        good = %w[name title id role text]
        tmp = main.select { |i| good.any? { |k| i['name'].include?(k) } }
        words = (tmp.map { |i| process_string(i['value'], vars) }).uniq
        words.sample
      end

      def so_so_name(main, vars)
        all = main.select { |i| i['type'] == 'attribute' }
        words = all.map { |i| process_string(i['value'], vars) }
        words.sample
      end

      def some_name(main, vars)
        result = good_name(main, vars)
        result = so_so_name(main, vars) if result.nil?
        result = "undescribed #{generate_word}" if result.nil?
        result
      end

      def suggest_name(name, attrs, vars)
        if name.to_s.empty?
          tag = attrs['0'].select { |i| i['type'] == 'tag' }
          tag = process_string(tag[0]['value'], vars)
          name = "#{some_name(attrs['0'], vars)} #{tag}"
        end
        suggest = name
        send_to_app('locatine_name', suggest)
        send_to_app('locatine_name_mark', 'true')
        suggest
      end

      def generate_word(pairs = 3)
        ss = 'qwrtpsdfghjklzxcvbnm'.split('')
        sa = 'eyuioa'.split('')
        str = ''
        pairs.times do
          str += ss.sample + sa.sample
        end
        str
      end
    end
  end
end
