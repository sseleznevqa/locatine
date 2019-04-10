module Locatine
  module ForSearch
    ##
    # Simple actions about communicating with chrome extension (and user)
    module Listening
      private

      ##
      # Getting attribute of locatine div (way to communicate)
      def get_from_app(what)
        fix_iframe
        result = engine.wd.execute_script(
          %[if (document.getElementById('locatine_magic_div')) {
             const magic_div = document.getElementById('locatine_magic_div');
             return magic_div.getAttribute("#{what}")}]
        )
        fix_iframe
        result
      end

      ##
      # Sending request to locatine app
      def start_listening(scope, name)
        send_to_app('locatinestyle', 'blocked', @browser) if @iframe
        send_to_app('locatinestyle', 'set_true')
        send_selecting(name, scope)
        sleep 0.5
      end

      def tag_index
        tag = get_from_app('tag')
        tag = tag.downcase unless tag.nil?
        index = get_from_app('index').to_i
        return tag, index
      end

      def response_action(element)
        send_to_app('locatineconfirmed', 'ok')
        send_has_response
        mass_highlight_turn(element, false) if element
        send_to_app('locatinestyle', 'set_false')
        send_to_app('locatinestyle', 'ok', @browser) if @iframe
        sleep 1
      end
    end
  end
end
