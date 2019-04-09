module Locatine
  module ForSearch
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

      def time
        t = Time.now
        "#{t.year}.#{t.month}.#{t.day}  #{t.hour.to_s.rjust(2, '0')}:"\
        "#{t.min.to_s.rjust(2, '0')}:#{t.sec.to_s.rjust(2, '0')}"
      end

      def fix_iframe
        @iframe = @browser.iframe(@iframe.selector) if @iframe && @iframe.stale?
      end

      def set_env_for_search(look_in, iframe, tolerance)
        @type = look_in
        @iframe = iframe
        @current_t = tolerance || @tolerance
      end

      def not_magic_div
        "[not(@id = 'locatine_magic_div')]"
      end

      def push_hash(name, value, type)
        { 'name' => name,
          'value' => value,
          'type' => type }
      end

      def window_size
        b_w = engine.execute_script('return window.innerWidth')
        b_h = engine.execute_script('return window.innerHeight')
        "#{b_w}x#{b_h}"
      end

      def visual?
        @visual_search
      end

      def right_browser
        Watir::Browser.new(:chrome, switches: ["--load-extension=#{HOME}/app"])
      end

      def import_browser(browser)
        selenium = browser.class.superclass == Selenium::WebDriver::Driver
        b = right_browser unless browser
        b = browser if browser.class == Watir::Browser
        b = Watir::Browser.new(browser) if selenium
        @browser = b
        @default_styles = default_styles.to_a
      end

      def css_text_to_hash(text)
        almost_hash = []
        array = text[0..-2].split('; ')
        array.each do |item|
          almost_hash.push item.split(': ')
        end
        almost_hash.to_h
      end

      def default_styles
        css =
          engine.execute_script("const dummy = document.createElement('dummy');
                                 document.body.appendChild(dummy);
                                 return getComputedStyle(dummy).cssText;")
        css_text_to_hash(css)
      end

      def process_string(str, vars)
        str = str.to_s
        thevar = str.match(/\#{([^\#{]*)}/)[1] unless str.match(/\#{(.*)}/).nil?
        return str unless thevar

        value = vars[thevar.to_sym] || vars[thevar]
        raise_no_var(thevar) unless value
        process_string(str.gsub('#{' + thevar + '}', value.to_s), vars)
      end
    end
  end
end
