module Locatine
  ##
  # Scope is the class representing group of elements
  #
  # Locatine has scopes
  class Scope
    def initialize(scope, search)
      @search = search
      @scope = scope
    end

    ##
    # Way to define locatine a bunch elements at once. Elements will be taken
    # from user selection one by one and saved in scope.
    #
    # Params:
    #
    # +vars+ hash of vars used for dynamic attributes. Same as in :find
    def define(vars = {})
      find_all(vars, false, true) if data.to_h != {}
      new_define(vars)
    end

    ##
    # Getting all the elements of the scope at once
    #
    # Params:
    #
    # +vars+ hash of vars used for dynamic attributes. Same as in :find
    def all(vars = {})
      find_all(vars)
    end

    ##
    # Checking all the elements of the scope at once.
    # Will fail if something was lost
    #
    # Params:
    #
    # +vars+ hash of vars used for dynamic attributes. Same as in :find
    def check(vars = {})
      success = []
      result = find_all(vars, true)
      result.each_pair do |name, hash|
        success.push name if hash[:elements].nil?
      end
      raise "Check of #{@scope} failed! Lost: #{success}" unless success.empty?

      result
    end

    private

    def data
      @search.data[@scope]
    end

    def find_one(name, hash, vars, strict)
      locator = { xpath: @search.send(:generate_xpath, hash, vars) } if strict
      elements = @search.collect(scope: @scope, name: name,
                                 locator: locator, exact: strict)
      locator = { xpath: @search.send(:generate_xpath, hash, vars) }
      { elements: elements, locator: locator }
    end

    def find_all(vars = {}, strict = false, define = false)
      learn = @search.learn
      @search.learn = define
      result = {}
      data.each_pair do |name, hash|
        result[name] = find_one(name, hash, vars, strict)
      end
      @search.learn = learn
      result
    end

    def new_define(vars)
      item = @search.send(:ask, @scope, '', nil, vars)
      return find_all(vars) if item[:element].nil?

      @search.send(:store, item[:attributes], @scope, item[:name])
      new_define(vars)
    end
  end
end
