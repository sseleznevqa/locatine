# frozen_string_literal: true

require 'locatine'

def set_page
  what = @component || @browser.url
  @search.json = "./pages/page_#{URI.parse(what).path.gsub('/', '')}.json"
end

Before do
  @search = Locatine::Search.new(json: './pages/default.json')
  @browser = @search.browser
  @base_url = 'google.com'
  @component = nil
end

at_exit do
  @browser.quit
end
