module Locatine
  ##
  # Different methods to make life easier
  module Helpers
    private

    def enforce(what, value, *args)
      if args.last.class == Hash
        args.last[what] = value
      else
        temp = {}
        temp[what] = value
        args.push(temp)
      end
      find(*args)
    end

    def engine
      (@iframe || @browser)
    end

    def not_magic_div
      "[not(@id = 'locatine_magic_div')]"
    end

    def right_browser
      Watir::Browser.new(:chrome, switches: ["--load-extension=#{HOME}/app"])
    end

    def process_string(str, vars)
      str = str.to_s
      thevar = str.match(/\#{([^\#{]*)}/)[1] unless str.match(/\#{(.*)}/).nil?
      return str unless thevar

      value = vars[thevar.to_sym] || vars[thevar]
      unless value
        raise ArgumentError, ":#{thevar} must be "\
          'provided in vars since element was defined with it'
      end
      process_string(str.gsub('#{' + thevar + '}', value.to_s), vars)
    end
  end
end
