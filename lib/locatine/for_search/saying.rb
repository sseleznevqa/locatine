module Locatine
  module ForSearch
    ##
    # texts, errors
    # rubocop:disable Metrics/ModuleLength
    module Saying
      private

      def send_info(message)
        puts "#{time}: #{message}"
      end

      def send_warn(message)
        warn "#{time}: WARNING: #{message}"
      end

      def verb(length)
        length > 1 ? 'elements were' : 'element was'
      end

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

      def push_title(text)
        send_info text
        send_to_app('locatinetitle', text)
      end

      def send_found(name, scope, length)
        push_title("#{length} #{verb(length)} found as #{name} in #{scope}"\
          ' using previously saved information')
      end

      def send_guessing(name, scope)
        push_title("Locatine is trying to guess what is #{name} in #{scope}.")
      end

      def send_selected(length, name, scope)
        push_title "#{length} #{verb(length)} selected as #{name} in "\
                  "#{scope}. If it is correct - confirm the selection."
      end

      def send_working(tag, index)
        push_title "You've selected //#{tag}[#{index}]."\
        ' Wait while Locatine works'
      end

      def send_lost
        push_title 'Selected element was lost before locatine locate it. '\
                 'Consider choosing it from devtools or write your own locator'
      end

      def send_clear(name, scope)
        name = 'some element' if name.to_s.empty?
        push_title "Now nothing is selected as #{name} in #{scope}"
      end

      def send_no_guess(name, scope)
        push_title "Locatine has no good guess for #{name} in #{scope}."
      end

      def send_has_guess(length, name, scope)
        push_title "#{length} #{verb(length)} guessed as #{name} in #{scope}."
      end

      def send_selecting(name, scope)
        name = 'some element' if name.to_s.empty?
        push_title "You are selecting #{name} in #{scope}"
        send_to_app('locatinehint', 'Toggle single//collection mode button if '\
          'you need. If you want to do some actions on the page toggle'\
          ' Locatine waiting button. You also can select element on devtools '\
          '-> Elements. Do not forget to confirm your selection.')
      end

      def send_has_response
        push_title 'Right now you are defining nothing. So no button will work'
        send_to_app('locatinehint', 'Your previous selection is confirmed. '\
          'Locatine is waiting for new find request')
      end

      def send_same_entry(length, name, scope, found)
        push_title "#{length} #{verb(length)} selected as #{name} in #{scope}."\
        " But it was already defined #{found.length} times."
        example = found.sample
        same = found.select { |i| (i[:name] == name) && (i[:scope] == scope) }
        if same.empty?
          send_same_entry_example(example)
        else
          send_fully_similar
        end
      end

      def send_same_entry_example(example)
        send_to_app('locatinehint', "For example like #{example[:name]} in"\
        " #{example[:scope]}")
      end

      def send_fully_similar
        send_to_app('locatinehint', 'And it was defined with the same name'\
        ' and in the same scope. So saving your selection will cause'\
        ' deleting of all previously stored data about the element')
      end

      def warn_dropping(tag, index)
        send_warn('For some reason locatine cannot proceed with'\
          " //#{tag}[#{index}] element. You've selected. Maybe element was"\
          ' changed somewhere in the middle of locatine work. If this error is'\
          'repeating you can try to select element via devtools or you can'\
          ' provide a locator')
      end

      def warn_type
        send_warn("Check also. Maybe #{tag} element cannot be found as @type?")
      end

      def warn_acceptable_type(method)
        send_warn "#{method} works for :look_in. But it is better to use a"\
         ' method of Watir::Browser that returns a collection (like :divs,'\
         ' :links, etc.)'
      end

      def warn_element_lost(name, scope)
        send_warn "#{name} in #{scope} is//are lost. Locatine is trying "\
                  'to find it anyway.'
      end

      def warn_cannot_highlight(data)
        send_warn "Something was found as #{data} but we cannot highlight it"
      end

      def warn_unstable
        send_warn 'It seems that page is unstable. It may lead to problems '\
                  'with resolving elements'
      end

      def warn_highly_unstable
        send_warn 'It seems that page is HIGHLY unstable. No guaranties now.'
      end

      def warn_much_highlight(size)
        send_warn "Only the first 50 elements of #{size} were highlighted."
      end

      def warn_lost_found(name, scope)
        send_warn "Something was found as #{name} in #{scope}."
      end

      def warn_not_found(name, scope)
        send_warn "Locatine cannot find element #{name} in #{scope}"
      end

      def warn_totally_same(how_deep)
        send_warn('There are more than one elements with totally similar'\
          " attributes. Custom depth for element is set to #{how_deep}.")
      end

      def warn_no_negatives
        send_warn 'The only way to find the selected element is to use'\
        " negative expression like //*[not(@id='something')]. Locatine does"\
        ' not support it. So you must to provide for element a custom locator.'\
        ' Or find it as a part of collection and than return it by index'
      end

      def raise_not_found(name, scope)
        raise "Locatine cannot find element #{name} in #{scope}"
      end

      def raise_not_similar(name, scope)
        raise "Locatine cannot find element similar to #{name} in #{scope}"
      end

      def raise_no_name
        raise ArgumentError, ':name is not provided.'
      end

      def raise_no_var(thevar)
        raise ArgumentError, ":#{thevar} must be "\
          'provided in vars since element was defined with it'
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
