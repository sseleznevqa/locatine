module Locatine
  ##
  # Methods explaining find logic
  module FindLogic
    private

    def set_name(simple_name, name)
      name ||= simple_name
      raise ArgumentError, ':name should be provided' unless name

      name
    end

    def core_search(result, name, scope, vars, exact)
      if @data[scope][name].to_h != {}
        result = find_by_data(@data[scope][name], vars)
        attributes = generate_data(result, vars) if result
        if !result && !exact
          result, attributes = find_by_magic(name, scope,
                                             @data[scope][name], vars)
        end
      end
      return result, attributes
    end

    def full_search(name, scope, vars, locator, exact)
      result, attributes = locator_search(locator, vars)
      unless result
        result, attributes = core_search(result, name, scope,
                                         vars, exact)
      end
      result, attributes = ask(scope, name, result, vars) if @learn
      raise "Nothing was found for #{scope} #{name}" if !result && !exact

      store(attributes, scope, name) if result
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
      case collection
      when true
        result
      when false
        result.first.to_subtype
      end
    end
  end
end
