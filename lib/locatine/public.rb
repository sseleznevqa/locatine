module Locatine
  ##
  # Public methods of the Search class
  module Public
    ##
    # Creates a new instance of Search
    #
    # Params:
    # +json+ is the name of file to store//read data. Default =>
    # "./Locatine_files/default.json"
    #
    # +depth+ is the value that shows how many data will be stored for element.
    #
    # +browser+ is the instance of Watir::Browser. Unless provided it gonna
    # be created with locatine-app onboard.
    #
    # +learn+ shows will locatine ask for assistance from user or will fail
    # on error. learn is true when LEARN parameter is set in environment.
    #
    # +stability_limit+ shows max times attribute should be present to
    # consider it trusted.
    #
    # +scope+ will be used in search (if not provided) defaulkt is "Default"
    #
    # +tolerance+ Shows how similar must be an element found as alternative
    # to the lost one. Default is 33 which means that if less than 33% of
    # metrics of alternative elements are the same as of the lost element
    # will not be returned
    def initialize(json: './Locatine_files/default.json',
                   depth: 3,
                   browser: nil,
                   learn: ENV['LEARN'].nil? ? false : true,
                   stability_limit: 10,
                   scope: 'Default',
                   tolerance: 33)
      import_browser browser
      import_file(json)
      @depth = depth
      @learn = learn
      @stability_limit = stability_limit
      @scope = scope
      @tolerance = tolerance
    end

    ##
    # Looking for the element
    #
    # Params:
    #
    # +scope+ is a parameter that is used to get information about the
    # element from @data. Default is "Default"
    #
    # +name+ is a parameter that is used to get information about the
    # element from @data. Must not be nil.
    #
    # +exact+ if true locatine will be forced to use only basic search.
    # Default is false
    #
    # +locator+ if not empty it is used for the first attempt to find the
    # element. Default is {}
    #
    # +vars+ hash of variables that will be used for dynamic attributes.
    # See readme for example
    #
    # +look_in+ only elements of that kind will be used. Use Watir::Browser
    # methods returning collections (:text_fields, :links, :divs, etc.)
    #
    # +iframe+ if provided locatine will look for elements inside of it
    #
    # +return_locator+ is to return a valid locator of the result
    #
    # +collection+ when true an array will be returned. When false - a
    # single element
    def find(simple_name = nil,
             name: nil,
             scope: nil,
             exact: false,
             locator: {},
             vars: {},
             look_in: nil,
             iframe: nil,
             return_locator: false,
             collection: false,
             tolerance: nil)
      name = set_name(simple_name, name)
      @type = look_in
      @iframe = iframe
      @tolerance ||= tolerance
      scope ||= @scope.nil? ? 'Default' : @scope
      result, attributes = full_search(name, scope, vars, locator, exact)
      return { xpath: generate_xpath(attributes, vars) } if result &&
                                                            return_locator
      return to_subtype(result, collection) if result && !return_locator
    end

    ##
    # Find alias with return_locator option enforced
    def lctr(*args)
      enforce(:return_locator, true, *args)
    end

    ##
    # Find alias with collection option enforced
    def collect(*args)
      enforce(:collection, true, *args)
    end

    def json=(value)
      import_file(value)
    end

    def browser=(value)
      import_browser(value)
    end
  end
end
