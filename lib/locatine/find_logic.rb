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

    def stable?(attributes)
      s = []
      attributes.each_pair do |_depth, array|
        s.push array.max_by { |item| item['stability'].to_i }['stability'].to_i
      end
      s.max > 1
    end

    def data_search(name, scope, vars, exact)
      result = find_by_data(@data[scope][name], vars)
      attributes = generate_data(result, vars) if result
      if !result && (!exact || !stable?(@data[scope][name]))
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
      result, attributes = locator_search(locator, vars)
      result, attributes = core_search(name, scope, vars, exact) unless result
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
