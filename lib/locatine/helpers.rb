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

    def import_browser(browser)
      s_class = browser.class.superclass
      b = right_browser unless browser
      b = browser if browser.class == Watir::Browser
      b = Watir::Browser.new(browser) if s_class == Selenium::WebDriver::Driver
      css = b.execute_script(%Q[const dummy = document.createElement('dummy');
                                document.body.appendChild(dummy);
                                return getComputedStyle(dummy);])
      @browser = b
      @default_styles = default_styles
    end

    def default_styles
      hash = {}
      css =
         engine.execute_script(%Q[const dummy = document.createElement('dummy');
                                  document.body.appendChild(dummy);
                                  return getComputedStyle(dummy);])
      element = engine.element(xpath: "//dummy")
      css.each do |style|
        hash[style] = element.style(style)
      end
      hash
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
