module Locatine
  ##
  # Simple actions about communicating with chrome extension (and user)
  module DialogActions
    private

    ##
    # Setting attribute of locatine div (way to communicate)
    def send_to_app(what, value, bro = engine)
      fix_iframe
      bro.wd.execute_script(
        %[if (document.getElementById('locatine_magic_div')){
          const magic_div = document.getElementById('locatine_magic_div');
           return magic_div.setAttribute("#{what}", "#{value}")}]
      )
      fix_iframe
    end

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

    def fix_iframe
      @iframe = @browser.iframe(@iframe.selector) if @iframe
    end

    def push_title(text)
      puts text
      send_to_app('locatinetitle', text)
    end

    ##
    # Sending request to locatine app
    def start_listening(_scope, _name)
      send_to_app('locatinestyle', 'blocked', @browser) if @iframe
      send_to_app('locatinehint', 'Toggle single//collection mode button if '\
        'you need. If you want to do some actions on the page toggle Locatine'\
        ' waiting button. You also can select element on devtools -> Elements.'\
        ' Do not forget to confirm your selection.')
      send_to_app('locatinestyle', 'set_true')
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
      send_to_app('locatinetitle', 'Right now you are defining nothing. '\
                                   'So no button will work')
      send_to_app('locatinehint', 'Place for a smart hint here')
      mass_highlight_turn(element, false)
      send_to_app('locatinestyle', 'set_false')
      send_to_app('locatinestyle', 'ok', @browser) if @iframe
      sleep 0.5
    end
  end
end
