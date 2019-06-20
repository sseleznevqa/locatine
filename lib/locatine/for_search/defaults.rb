module Locatine
  module ForSearch
    ##
    # Default settings for search are living here
    module Defaults
      private
      def default_init_config
        { json: './Locatine_files/default.json',
          depth: 3,
          browser: nil,
          learn: ENV['LEARN'].nil? ? false : true,
          stability_limit: 10,
          scope: 'Default',
          tolerance: 67,
          visual_search: false,
          no_fail: false,
          trusted: [],
          untrusted: [],
          autolearn: nil
        }
      end

      def import_browser(browser)
        selenium = browser.class.superclass == Selenium::WebDriver::Driver
        b = right_browser unless browser
        b = browser if browser.class == Watir::Browser
        b = Watir::Browser.new(browser) if selenium
        @browser = b
        @default_styles = default_styles.to_a
      end

      def import_file(json)
        @json = json
        @folder = File.dirname(@json)
        @name = File.basename(@json)
        @data = read_create
      end

      def import_config(config)
        config.each_pair do |key, value|
          self.instance_variable_set("@#{key.to_s}", value)
        end
      end
    end
  end
end
