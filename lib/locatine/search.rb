require "watir"
require "json"
require "fileutils"
require "chromedriver-helper"

module Locatine

  ##
  # Search is the main class of the Locatine
  #
  # Locatine can search.
  class Search

    attr_accessor :data, :depth, :browser, :learn, :json, :stability_limit, :scope

    ##
    # Creates a new instance of Search
    #
    # Params:
    # +json+ is the name of file to store//read data. Default => "./Locatine_files/default.json"
    #
    # +depth+ is the value that shows how many data will be stored for element.
    #
    # +browser+ is the instance of Watir::Browser. Unless provided it gonna be created with locatine-app onboard.
    #
    # +learn+ shows will locatine ask for assistance from user or will fail on error. learn is true when LEARN parameter is set in environment.
    #
    # +stability_limit+ shows max times attribute should be present to consider it trusted.
    #
    # +scope+ will be used in search (if not provided) defaulkt is "Default"
    def initialize(json: "./Locatine_files/default.json",
                   depth: 3,
                   browser: nil,
                   learn: ENV['LEARN'].nil? ? false : true,
                   stability_limit: 10,
                   scope: "Default")
      if !browser
        @browser = Watir::Browser.new(:chrome, switches: ["--load-extension=#{HOME}/app"])
      else
        @browser = browser
      end
      @json = json
      @folder = File.dirname(@json)
      @name = File.basename(@json)
      @depth = depth
      @data = read_create
      @learn = learn
      @stability_limit = stability_limit
      @scope = scope
    end

    ##
    # Looking for the element
    #
    # Params:
    #
    # +scope+ is a parameter that is used to get information about the element from @data. Default is "Default"
    #
    # +name+ is a parameter that is used to get information about the element from @data. Must not be nil.
    #
    # +exact+ if true locatine will be forced to use only basic search. Default is false
    #
    # +locator+ if not empty it is used for the first attempt to find the element. Default is {}
    #
    # +vars+ hash of variables that will be used for dynamic attributes. See readme for example
    #
    # +look_in+ only elements of that kind will be used. Use Watir::Browser methods returning collections (:text_fields, :links, :divs, etc.)
    #
    # +iframe+ if provided locatine will look for elements inside of it
    def find(simple_name = nil, name: nil, scope: nil, exact: false, locator: {}, vars: {}, look_in: nil, iframe: nil, return_locator: false)
      name ||= simple_name
      raise ArgumentError, ":name should be provided" if !name
      @type = look_in
      @iframe = iframe
      scope = @scope if scope.nil?
      scope = "Default" if scope.nil?
      result = find_by_locator(locator) if locator != {}
      if !result
        if @data[scope][name].to_h != {}
          result = find_by_data(@data[scope][name], vars)
          attributes = generate_data(result, vars) if result
          if !result && !exact
            result, attributes = find_by_magic(name, scope, @data[scope][name], vars)
          end
        end
      end
      result, attributes = ask(scope, name, result, vars) if @learn
      raise RuntimeError, "Nothing was found for #{scope} #{name}" if !result
      attributes = generate_data(result, vars) if !attributes
      @type = nil
      store(attributes, scope, name)
      return return_locator ? {xpath: generate_xpath(attributes, vars)} : to_subtype(result)
    end

    ##
    # Find alias with return_locator option enforced
    def lctr(*args)
      if args.last.class == Hash
        args.last[:return_locator] = true
      else
        args.push({return_locator: true})
      end
      find(args)
    end

    private

    ##
    # Reading data from provided file which is set on init of the class instance
    #
    # If there is no dir or\and file they will be created
    def read_create
      unless File.directory?(@folder)
        FileUtils.mkdir_p(@folder)
      end
      if File.exists?(@json)
        hash = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = {}}}
        return hash.merge(JSON.parse(File.read(@json))["data"])
      else
        f = File.new(@json, "w")
        f.puts '{"data" : {}}'
        f.close
        return Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = {}}}
      end
    end

    def engine
      return (@iframe || @browser)
    end

    def collection?(the_class)
      case the_class.superclass.to_s
      when "Object"
        return nil
      when "Watir::Element"
        return false
      when "Watir::ElementCollection"
        return true
      else
        return collection?(the_class.superclass)
      end
    end

    ##
    # Getting all the elements matching a locator
    def find_by_locator(locator)
      method = @type.nil? ? :elements : @type
      results = engine.send(method, locator)
      case collection?(results.class)
      when nil
        @type = nil
        raise ArgumentError, "#{method} is not good for :look_in property. Use a method of Watir::Browser that returns a collection (like :divs, :links, etc.)"
      when true
        begin
          results[0].wait_until(timeout: @cold_time) { |el| el.present? }
          return results
        rescue
          return nil
        end
      when false
        begin
          warn "#{method} works for :look_in. But it is better to use a method of Watir::Browser that returns a collection (like :divs, :links, etc.)"
          results.wait_until(timeout: @cold_time) { |el| el.present? }
          the_class = results.class
          results = engine.elements(locator).to_a.select{|item| item.to_subtype.class == the_class}
          return results
        rescue
          return nil
        end
      end
    end

    def get_trusted(array)
      if array.length > 0
        max_stability = (array.max_by {|i| i["stability"].to_i})["stability"].to_i
        return (array.select {|i| i["stability"].to_i == max_stability}).uniq
      else
        return []
      end
    end

    def generate_xpath(data, vars)
      xpath = ''
      data.each_pair do |depth, array|
        trusted = get_trusted(array)
        trusted.each do |hash|
          case hash["type"]
          when "tag"
            xpath = "[self::#{process_string(hash["value"], vars)}]" + xpath
          when "text"
            xpath = "[contains(text(), '#{process_string(hash["value"], vars)}')]" + xpath
          when "attribute"
            full_part = "[@*"
            hash["name"].split("_").each do |part|
              full_part = full_part + "[contains(name(), '#{part}')]"
            end
            xpath = full_part + "[contains(., '#{process_string(hash["value"], vars)}')]]" + xpath
          end
        end
        xpath = '/*' + xpath
      end
      xpath = '/' + xpath
      return xpath
    end

    ##
    # Getting all the elements via stored information
    def find_by_data(data, vars)
      find_by_locator({xpath: generate_xpath(data, vars)})
    end

    ##
    # Getting all the elements via black magic
    def find_by_magic(name, scope, data, vars)
      warn "Cannot locate #{name} in #{scope} with usual ways. Trying to use magic"
      all = []
      timeout = @cold_time
      @cold_time = 0
      data.each_pair do |depth, array|
        trusted = get_trusted(array)
        trusted.each do |hash|
          case hash["type"]
          when "tag"
            all = all + find_by_tag(hash, vars, depth).to_a
          when "text"
            all = all + find_by_text(hash, vars, depth).to_a
          when "attribute"
            all = all + find_by_attribute(hash, vars, depth).to_a
          end
        end
      end
      @cold_time = timeout
      raise RuntimeError, "Locatine is unable to find element #{name} in #{scope}" if all.length == 0
      # Something esoteric here :)
      max = all.count(all.max_by {|i| all.count(i)})
      suggestion = (all.select {|i| all.count(i) == max}).uniq
      attributes = generate_data(suggestion, vars)
      return suggestion, attributes
    end

    ##
    # Getting elements by attribute
    def find_by_attribute(hash, vars, depth = 0)
      correction = "/*" * depth.to_i
      full_part = "//*[@*"
      hash["name"].split("_").each do |part|
        full_part = full_part + "[contains(name(), '#{part}')]"
      end
      xpath = full_part + "[., '#{process_string(hash["value"], vars)}')]]"
      find_by_locator(xpath: "#{full_part}[contains(., '#{process_string(hash["value"], vars)}')]]#{correction}")
    end

    ##
    # Getting elements by tag
    def find_by_tag(hash, vars, depth = 0)
      correction = "/*" * depth.to_i
      find_by_locator(xpath: "//*[self::#{process_string(hash["value"], vars)}')]#{correction}")
    end

    ##
    # Getting elements by text
    def find_by_text(hash, vars, depth = 0)
      correction = "/*" * depth.to_i
      find_by_locator(xpath: "//*[contains(text(), '#{process_string(hash["value"], vars)}')]#{correction}")
    end

    ##
    # Setting attribute of locatine div (way to communicate)
    def send_to_app(what, value, b = engine)
      fix_iframe
      b.wd.execute_script(%Q[if (document.getElementById('locatine_magic_div')) {
                                  return document.getElementById('locatine_magic_div').setAttribute("#{what}", "#{value}")}])
      fix_iframe
    end

    ##
    # Getting attribute of locatine div (way to communicate)
    def get_from_app(what)
      fix_iframe
      result = engine.wd.execute_script(%Q[if (document.getElementById('locatine_magic_div')) {
                                  return document.getElementById('locatine_magic_div').getAttribute("#{what}")}])
      fix_iframe
      return result
    end

    def fix_iframe
      if @iframe
        @iframe = @browser.iframe(@iframe.selector)
      end
    end

    ##
    # Sending request to locatine app
    def start_listening(scope, name)
      send_to_app("locatinestyle", "blocked", @browser) if @iframe
      puts "You are defining #{name} in #{scope}" # TODO send to app
      send_to_app("locatinetitle", "You are defining #{name} in #{scope}.")
      send_to_app("locatinehint", "Toggle single//collection mode button if you need. If you want to do some actions on the page toggle Locatine waiting button. You also can select element on devtools -> Elements. Do not forget to confirm your selection.")
      send_to_app("locatinestyle", "set_true")
      sleep 0.5
    end

    def find_by_guess(scope, name, vars)
      all = []
      timeout = @cold_time
      @cold_time = 0
      name.split(" ").each do |part|
        all = all + find_by_locator({tag_name: part}).to_a
        all = all + find_by_locator({xpath: "//*[contains(text(),'#{part}')]"}).to_a
        all = all + find_by_locator({xpath: "//*[@*[contains(., '#{part}')]]"}).to_a
      end
      if all.length>0
        max = all.count(all.max_by {|i| all.count(i)})
        guess = (all.select {|i| all.count(i) == max}).uniq
        guess_data = generate_data(guess, vars)
        by_data = find_by_data(guess_data, vars)
        if by_data.nil? || (engine.elements.length/find_by_data(guess_data, vars).length <=4)
          puts "Locatine has no good guess for #{name} in #{scope}. Try to change the name. Or just define it."
          guess = nil
          guess_data = {}
        end
      else
        puts "Locatine has no guess for #{name} in #{scope}. Try to change the name. Or just define it."
      end
      @cold_time = timeout
      return guess, guess_data.to_h
    end

    ##
    # request send and waiting for an answer
    def ask(scope, name, result, vars)
      start_listening(scope, name)
      element, attributes, finished, old_tag, old_index, old_element = result, {}, false, nil, nil, nil
      if !element.nil?
        attributes = generate_data(element, vars)
      else
        element, attributes = find_by_guess(scope, name, vars) if name.length >= 5
      end
      while !finished do
        sleep 0.1
        tag = get_from_app("tag")
        tag = tag.downcase if !tag.nil?
        index = get_from_app("index").to_i
        if (!tag.to_s.strip.empty?) && ((tag != old_tag) or (old_index != index))
          element = [engine.elements({tag_name: tag})[index]]
          new_attributes = generate_data(element, vars)
          if get_from_app("locatinecollection") == "true"
            attributes = get_commons(new_attributes, attributes)
            element = find_by_data(attributes, vars)
          else
            attributes = new_attributes
          end
        end
        if old_element != element
          mass_highlight_turn(old_element, false) if old_element
          mass_highlight_turn(element) if element
          if element.nil?
            puts "Nothing is selected as #{name} in #{scope}"
          else
            puts "#{element.length} elemens were selected as #{name} in #{scope}"
          end
        end
        old_element, old_tag, old_index = element, tag, index
        case get_from_app("locatineconfirmed")
        when "true"
          send_to_app("locatineconfirmed", "ok")
          send_to_app("locatinetitle", "Right now you are defining nothing. So no button will work")
          send_to_app("locatinehint", "Place for a smart hint here")
          finished = true
        when "declined"
          send_to_app("locatineconfirmed", "ok")
          element, old_tag, old_index, tag, index, attributes = nil, nil, nil, nil, nil, {}
        end
      end
      mass_highlight_turn(element, false)
      send_to_app("locatinestyle", "ok", @browser) if @iframe
      sleep 0.5
      return element, attributes
    end

    ##
    # We can highlight an element
    def highlight(element)
      if !element.stale? && element.exists?
        begin
          engine.execute_script("arguments[0].setAttribute"\
                            "('locatineclass','foundbylocatine')", element)
        rescue
          warn " something was found as #{element.selector} but we cannot highlight it"
        end
      end
    end

    ##
    # We can unhighlight an element
    def unhighlight(element)
      if !element.stale? && element.exists?
        begin
          engine.execute_script("arguments[0].removeAttribute('locatineclass')",
                              element)
        rescue
          # watir is not allowing to play with attributes of some strange elements
        end
      end
    end

    ##
    # We can highlight\unhighlight tons of elements at once
    def mass_highlight_turn(mass, turn_on = true)
      mass.each do |element|
        if turn_on
          highlight element
        else
          unhighlight element
        end
      end
    end

    ##
    # Generating array of hashes representing data of the element
    def get_element_info(element, vars)
      attrs = []
      get_attributes(element).each do |hash|
        if vars[hash["name"].to_sym]
          hash["value"].gsub!(vars[hash["name"].to_sym], "\#{#{hash["name"]}}")
        end
        attrs.push hash
      end
      txt = (element.text == element.inner_html) ? element.text : ''
      tag = element.tag_name
      if vars[:tag] == tag
        tag = "\#{tag}"
      end
      attrs.push({"name" => "tag", "value" => tag, "type" => "tag"})
      txt.split(" ").each do |word|
        if !vars[:text].to_s.strip.empty?
          final_word = word.gsub(vars[:text].to_s, "\#{text}")
        else
          final_word = word
        end
        attrs.push({"name" => "text", "value" => final_word, "type" => "text"})
      end
      return attrs
    end

    ##
    # Merging data of two elements (new data is to find both)
    def get_commons(first, second)
      second = first if second == {}
      final = Hash.new { |hash, key| hash[key] = [] }
      first.each_pair do |depth, array|
        array.each do |hash|
          to_add = second[depth].select {|item| (item["name"] == hash["name"]) and (item["value"] == hash["value"]) and item["type"] == hash["type"]}
          final[depth] = final[depth] + to_add
        end
      end
      final
    end

    ##
    # Setting stability
    def set_stability(first, second)
      second = first if second.to_h == {}
      final = Hash.new { |hash, key| hash[key] = [] }
      first.each_pair do |depth, array|
        array.each do |hash|
          to_add = second[depth].select {|item| (item["name"] == hash["name"]) and (item["value"] == hash["value"]) and item["type"] == hash["type"]}
          if to_add.length > 0 # old ones
            to_add[0]["stability"] = (to_add[0]["stability"].to_i + 1).to_s if (to_add[0]["stability"].to_i < @stability_limit)
            final[depth] = final[depth] + to_add
          else # new ones
            hash["stability"] = "1"
            final[depth] = final[depth].push hash
          end
        end
        final[depth].uniq!
      end
      final
    end

    ##
    # Generating data for group of elements
    def generate_data(result, vars)
      family = {}
      result.each do |item|
        family = get_commons(get_family_info(item, vars), family)
      end
      return family
    end

    ##
    # Getting element\\parents information
    def get_family_info(element, vars)
      current_depth = 0
      attributes = {};
      while current_depth != @depth
        attributes[current_depth.to_s] = get_element_info(element, vars)
        current_depth = current_depth+1
        element = element.parent
        # Sometimes watir is not returning a valid parent that's why:
        current_depth = @depth if !element.parent.exists?
      end
      return attributes
    end

    ##
    # Saving json
    def store(attributes, scope, name)
      @data[scope][name] = set_stability(attributes, @data[scope][name])
      to_write = ({"data" => @data})
      File.open(@json, "w") do |f|
        f.write(JSON.pretty_generate(to_write))
      end
    end

    ##
    # Collecting attributes of the element
    def get_attributes(element)
      attributes = element.attributes
      array = Array.new
      attributes.each_pair do |name, value|
        if (name.to_s != "locatineclass")
          value.split(" ").uniq.each do |part|
            array.push({"name" => name.to_s, "type" => "attribute", "value" => part})
          end
        end
      end
      return array
    end

    ##
    # Replacing dynamic entries with values
    def process_string(str, vars)
      str ||= ""
      n = nil
      while str != n
        str = n if !n.nil?
        thevar = str.match(/\#{[^\#{]*}/).to_s
        if thevar != ""
          value = vars[thevar.match(/(\w.*)}/)[1].to_sym]
          raise ArgumentError, ":#{thevar.match(/(\w.*)}/)[1]} must be provided in vars since element was defined with it" if !value
          n = str.gsub(thevar, value)
        else
          n = str
        end
      end
      str
    end

    ##
    # Returning subtype of the only element of collection OR collection
    #
    # Params:
    # +result+ must be Watir::HTMLElementCollection or Array
    def to_subtype(result)
      if result.size == 1
        return result[0].to_subtype
      else
        return result
      end
    end
  end

end
