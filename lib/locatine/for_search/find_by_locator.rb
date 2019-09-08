module Locatine
  module ForSearch
    ##
    # Methods related to the most simple search by ready locator.
    module FindByLocator
      private

      def collection?(the_class)
        case the_class.superclass.to_s
        when 'Watir::Element'
          false
        when 'Watir::ElementCollection'
          true
        else
          collection?(the_class.superclass)
        end
      end

      ##
      # Getting all the elements matching a locator
      def find_by_locator(locator)
        method = @type.nil? ? :elements : @type
        begin
          engine.element(locator).wait_until(timeout: @cold_time, &:exists?)
        rescue StandardError
          return nil
        end
        results = engine.send(method, locator)
        return correct_method_detected(results) if collection?(results.class)

        acceptable_method_detected(results, method, locator)
      end

      def correct_method_detected(results)
        return nil if results.empty?

        all = results.reject(&:stale?)
        return all unless all.empty?

        nil
      end

      def acceptable_method_detected(results, method, locator)
        warn_acceptable_type(method)
        the_class = results.class
        results = engine.elements(locator)
                        .to_a
                        .select { |item| item.to_subtype.class == the_class }
        correct_method_detected(results)
      end

      ##
      # Getting all the elements via stored information
      def find_by_data(data, vars)
        find_by_locator(xpath: generate_xpath(data, vars))
      end
    end
  end
end
