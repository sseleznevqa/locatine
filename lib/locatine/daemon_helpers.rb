module Locatine
  #
  # Usefull things daemon can do
  module DaemonHelpers
    private

    def steal
      cast_ghost_browser
      disguise_session
      disguise_server_url
      disguise_http
      disguise_proxy unless params['proxy'].to_s.empty?
    end

    def bridge
      search.browser.wd.send(:bridge)
    end

    def b_http
      bridge.send(:http)
    end

    def disguise_session
      bridge.instance_variable_set('@session_id', params['session_id'])
    end

    def disguise_server_url
      uri = URI.parse(params['url'])
      b_http.instance_variable_set('@server_url', uri)
    end

    def disguise_http
      b_http.instance_variable_set('@http', make_net)
    end

    def disguise_proxy
      b_http.instance_variable_set('@proxy', params['proxy'])
    end

    def make_net
      parsed = URI.parse(params['url'])
      path = parsed.path == '/' ? '' : parsed.path
      Net::HTTP.new("#{parsed.host}#{path}", parsed.port)
    end

    def cast_ghost_browser
      search.browser = Watir::Browser.new(params['browser'].to_sym)
      search.browser.quit
      search.browser.instance_variable_set('@closed', false)
    end
  end
end
