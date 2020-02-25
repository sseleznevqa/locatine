# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    #
    # Trying to guess element here
    module Guess
      def guess
        warn_guess
        @config['tolerance'] = 100
        magic = Thread.new do
          magic_find(guess_data)
        end
        sleep 0.1 while timer && !similar?
        magic.kill
        normalize_indexes(magic['out']) if empty? && (magic['out'].to_h != {})
      end

      def main_guess_data
        answer = { '0' => [] }
        parts = @name.split(/[\s\'\\]/)
        parts.each do |item|
          next if item.to_s.empty?

          answer['0'].push('type' => '*',
                           'name' => '*',
                           'value' => item)
        end
        answer
      end

      def guess_data
        answer = main_guess_data
        # We expecting tag at the last position.
        last = @name.split(/[\s\'\\]/).last.to_s
        unless last.empty?
          answer['0'].push('type' => 'tag',
                           'name' => 'tag',
                           'value' => last)
        end
        answer
      end
    end
  end
end
