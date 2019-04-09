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

    def define(vars = {})
      item = @search.send(:ask, @scope, '', nil, vars)
      return if item[:element].nil?

      @search.send(:store, item[:attributes], @scope, item[:name])
      define(vars)
    end
  end
end
