# frozen_string_literal: true

module Locatine
  module ResultsHelpers
    #
    # Trying to compare elements here
    module Comparing
      private

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
      rescue RuntimeError => e
        raise e.message unless e.message == 'stale element reference'

        warn_unstable_page
        false
      end

      def similar_enough(same, all)
        sameness = (same * 100) / all
        sameness >= 100 - tolerance
      end

      def info_hash_eq(item, hash)
        # Return true
        # If type is unknown (but not a text)
        # Or when type and name are similar
        (unknown_no_text(item, hash) || same_name_type(item, hash)) &&
          # And at the same time values are (almost) the same
          (item['value'].downcase == hash['value'].downcase)
      end
    end
  end
end
