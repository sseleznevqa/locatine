# frozen_string_literal: true

module Locatine
  module DaemonHelpers
    #
    # Methods that are used by daemon
    module Methods
      def api_request(type, path, query_string, body, new_headers)
        uri = make_uri(path, query_string)
        req = Net::HTTP.const_get(type).new(uri,
                                            settings.headers.merge(new_headers))
        req.body = body.read
        Net::HTTP.new(uri.hostname, uri.port).start { |http| http.request(req) }
      end

      def make_uri(path, query_string)
        parsed = URI.parse selenium
        URI::HTTP.build(
          host: parsed.host,
          port: parsed.port,
          path: path,
          query: query_string
        )
      end

      def all_headers(response)
        header_list = {}
        response.header.each_capitalized do |k, v|
          header_list[k] = v unless k == 'Transfer-Encoding'
        end
        header_list
      end

      def incomming_headers(request)
        request.env.map do |header, value|
          if header.start_with?('HTTP_')
            [header[5..-1].split('_').map(&:capitalize).join('-'), value]
          end
        end .compact.to_h
      end

      def send_answer(response)
        content_type settings.headers['Content-Type']
        status response.code
        headers all_headers(response)
        response.body
      end

      def call_process(verb)
        start_request = Thread.new do
          api_request(verb.capitalize, request.path_info, request.query_string,
                      request.body, incomming_headers(request))
        end
        send_answer(start_request.value)
      end

      def params
        request.body.rewind
        JSON.parse request.body.read
      end

      def selenium
        settings.selenium
      end

      def raise_not_found
        status 404
        { value: { error: 'no such element',
                   message: 'no such element: Unable to locate element',
                   stacktrace: 'Locatine has no idea too' } }.to_json
      end

      def session_id
        request.path_info.split('/')[4]
      end

      def element_id
        path_array = request.path_info.split('/')
        path_array.size >= 7 ? path_array[6] : nil
      end
    end
  end
end
