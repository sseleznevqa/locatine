module Locatine
  ##
  # Logic of recieving element selected by user
  module DialogLogic
    private

    def suggest_element(element, vars, name, scope)
      attributes = {}
      if !element.nil?
        attributes = generate_data(element, vars)
        push_title("#{element.length} elements found as #{name} in #{scope}.")
      elsif name.length >= 5
        push_title("Locatine is trying to guess what is #{name} in #{scope}.")
        element, attributes = find_by_guess(scope, name, vars)
      end
      mass_highlight_turn(element) if element
      return element, attributes
    end

    def add_selected_attributes(new_attributes, attributes)
      if get_from_app('locatinecollection') == 'true'
        get_commons(new_attributes, attributes.to_h)
      else
        new_attributes
      end
    end

    def selected_element_attributes(tag, index, vars)
      generate_data([engine.elements(tag_name: tag)[index]], vars).to_h
    end

    def selected_element(tag, index, vars, attributes)
      new_attributes = selected_element_attributes(tag, index, vars)
      new_attributes = add_selected_attributes(new_attributes, attributes)
      element = find_by_data(new_attributes, vars)
      return element, new_attributes
    end

    def working_on_selected(tag, index, vars, attributes)
      push_title "You've selected //#{tag}[#{index}]. Wait while Locatine works"
      element, new_attributes = selected_element(tag, index, vars, attributes)
      warn 'Cannot proceed with selected. Dropping it.' unless element

      warn "Maybe #{tag} can't be found as a #{@type}?" if @type && !element

      return_selected(element, attributes, new_attributes, vars)
    end

    def return_old_selection(attrs, vars)
      return find_by_data(attrs, vars).to_a, attrss.to_h if attrs.to_h != {}

      return nil, {}
    end

    def return_selected(element, attributes, new_attributes, vars)
      if !element && new_attributes.to_h != {}
        push_title 'Selected element was lost before locatine locate it. '\
                 'Consider choosing it from devtools or write your own locator'
        return return_old_selection(attributes, vars)

      end
      return element, new_attributes
    end

    def what_was_selected(element, attributes, vars, name, scope)
      tag, index = tag_index
      send_to_app('locatineconfirmed', 'ok')
      mass_highlight_turn(element, false) if element
      element, attributes = working_on_selected(tag, index, vars, attributes)
      if element
        mass_highlight_turn(element)
        push_title "#{element.length} elements were selected as #{name} in "\
                  "#{scope}. If it is correct - confirm the selection."
      end
      return element, attributes
    end

    def decline(element, name, scope)
      mass_highlight_turn(element, false) if element
      send_to_app('locatineconfirmed', 'ok')
      push_title "Nothing is selected as #{name} in #{scope}"
      return nil, {}
    end

    def listening(els, attrs, vars, name, scope)
      until get_from_app('locatineconfirmed') == 'true'
        sleep(0.1)
        case get_from_app('locatineconfirmed')
        when 'selected'
          els, attrs = what_was_selected(els, attrs, vars, name, scope)
        when 'declined'
          els, attrs = decline(els, name, scope)
        end
      end
      return els, attrs
    end

    ##
    # request send and waiting for an answer
    def ask(scope, name, element, vars)
      start_listening(scope, name)
      element, attributes = suggest_element(element, vars, name, scope)
      @cold_time = 0
      element, attributes = listening(element, attributes, vars, name, scope)
      @cold_time = nil
      response_action(element)
      return element, attributes
    end
  end
end
