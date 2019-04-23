module Locatine
  module ForSearch
    ##
    # Methods explaining find logic
    module FindLogic
      private

      def set_name(simple_name, name)
        name ||= simple_name
        raise_no_name unless name
        name
      end

      def data_search(name, scope, vars, exact)
        result = find_by_data(@data[scope][name], vars)
        attributes = generate_data(result, vars) if result
        if !result && !exact
          result, attributes = find_by_magic(name, scope,
                                             @data[scope][name], vars)
        end
        return result, attributes
      end

      def core_search(name, scope, vars, exact)
        if @data[scope][name].to_h != {}
          result, attributes = data_search(name, scope, vars, exact)
        end
        return result, attributes
      end

      def full_search(name, scope, vars, locator, exact)
        result, attributes = search_steps(name, scope, vars, locator, exact)
        raise_not_found(name, scope) if !result && !@current_no_f
        store(attributes, scope, name) if result
        return result, attributes
      end

      def search_steps(name, scope, vars, locator, exact)
        result, attributes = locator_search(locator, vars)
        ok = result || ((locator != {}) && exact)
        result, attributes = core_search(name, scope, vars, exact) unless ok
        if @learn
          answer = ask(scope, name, result, vars)
          result = answer[:element]
          attributes = answer[:attributes]
        end
        return result, attributes
      end

      def locator_search(locator, vars)
        result = find_by_locator(locator) if locator != {}
        attributes = generate_data(result, vars) if result
        return result, attributes
      end

      ##
      # Returning subtype of the only element of collection OR collection
      #
      # Params:
      # +result+ must be Watir::HTMLElementCollection or Array
      #
      # +collection+ nil, true or false
      def to_subtype(result, collection)
        result = result.to_a
        to_return = result.map(&:to_subtype)
        case collection
        when true
          to_return
        when false
          to_return.first
        end
      end
    end
  end
end
