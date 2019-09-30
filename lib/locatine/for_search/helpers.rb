module Locatine
  module ForSearch
    ##
    # Different methods to make life easier
    module Helpers
      private

      def enforce(inject, *args)
        inject = args.last.merge(inject) if args.last.class == Hash
        ok = (args.first.class == String) && inject[:name].nil?
        inject[:name] = args.first if ok
        find(inject)
      end

      def engine
        (@iframe || @browser)
      end

      def take_html
        engine.locate
        engine.html.gsub(/<div.*id="locatine_magic_div".*>/, '')
      end

      def time
        t = Time.now
        t.strftime('%F %T')
      end

      def fix_iframe
        @iframe = @browser.iframe(@iframe.selector) if @iframe && @iframe.stale?
      end

      def set_env_for_search(look_in,
                             iframe,
                             tolerance,
                             no_fail,
                             trusted,
                             untrusted)
        @type = look_in
        @iframe = iframe
        @current_t = tolerance || @tolerance
        @current_no_f = no_fail || @no_fail
        @trust_now = trusted || @trusted
        @untrust_now = untrusted || @untrusted
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

      def most_common_of(all)
        max = all.count(all.max_by { |i| all.count(i) })
        return (all.select { |i| all.count(i) == max }).uniq unless max.zero?

        []
      end
    end
  end
end
