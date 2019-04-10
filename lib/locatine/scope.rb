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
    # Way to show locatine a bunch elements at once. Elements will be taken
    # from user selection one by one and saved in scope.
    #
    # Params:
    #
    # +vars+ hash of vars used for dynamic attributes. Same as in :find
    def define(vars = {})
      item = @search.send(:ask, @scope, '', nil, vars)
      return if item[:element].nil?

      @search.send(:store, item[:attributes], @scope, item[:name])
      define(vars)
    end
  end
end
