module Locatine
  module ForSearch
    ##
    # Logic of recieving element selected by user
    module DialogLogic
      private

      def suggest_element(element, vars, name, scope)
        attributes = {}
        if !element.nil?
          attributes = generate_data(element, vars)
          send_found(name, scope, element.length)
        elsif name.length >= 5
          send_guessing(name, scope)
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

      # Similar elements bug\\feature draft
      def selected_element_attributes(tag, index, vars)
        element = engine.elements(tag_name: tag)[index]
        attrs = generate_data([element], vars).to_h
        array = find_by_data(attrs, vars)
        number = array.length
        old_depth = @depth
        while array.length > 1
          attrs = get_family_info(element, vars).to_h
          array = find_by_data(attrs, vars)
          @depth += 1
        end
        warn_totally_same(@depth, number)
        @depth = old_depth
        attrs
      end

      def warn_totally_same(how_deep, how_many)
        send_warn("There are #{how_many} elements with totally similar"\
          " attributes. Custom depth for element is set to #{how_deep}.")
      end



      def selected_element(tag, index, vars, attributes)
        new_attributes = selected_element_attributes(tag, index, vars)
        new_attributes = add_selected_attributes(new_attributes, attributes)
        element = find_by_data(new_attributes, vars)
        return element, new_attributes
      end

      def working_on_selected(tag, index, vars, attributes)
        send_working(tag, index)
        element, new_attributes = selected_element(tag, index, vars, attributes)
        warn_dropping(tag, index) unless element

        warn_type(tag) if @type && !element

        return_selected(element, attributes, new_attributes, vars)
      end

      def return_old_selection(attrs, vars)
        return find_by_data(attrs, vars).to_a, attrs.to_h if attrs.to_h != {}

        return nil, {}
      end

      def return_selected(element, attributes, new_attributes, vars)
        if !element && new_attributes.to_h != {}
          send_lost
          return return_old_selection(attributes, vars)

        end
        return element, new_attributes
      end

      def what_was_selected(element, attributes, vars)
        tag, index = tag_index
        send_to_app('locatineconfirmed', 'ok')
        mass_highlight_turn(element, false) if element
        element, attributes = working_on_selected(tag, index, vars, attributes)
        return element, attributes
      end

      def show_element(element, attributes, name, scope)
        found = find_in_data(attributes)
        mass_highlight_turn(element)
        send_selected(element.length, name, scope) unless found
        send_same_entry(element.length, name, scope, found) if found
      end

      def decline(element, name, scope)
        mass_highlight_turn(element, false) if element
        send_to_app('locatineconfirmed', 'ok')
        send_clear(name, scope)
        return nil, {}
      end

      def user_selection(els, attrs, vars, name, scope)
        case get_from_app('locatineconfirmed')
        when 'selected'
          els, attrs = what_was_selected(els, attrs, vars)
          name = suggest_name(name, attrs, vars)
          show_element(els, attrs, name, scope) if els
        when 'declined'
          els, attrs = decline(els, name, scope)
        end
        return els, attrs
      end

      def listening(els, attrs, vars, name, scope)
        until %w[true abort].include?(get_from_app('locatineconfirmed'))
          sleep(0.1)
          els, attrs = user_selection(els, attrs, vars, name, scope)
        end
        result = get_from_app('locatineconfirmed')
        return els, attrs if els && result != 'abort'

        els, attrs = decline(els, name, scope)
        return els, attrs if result == 'abort'

        listening(els, attrs, vars, name, scope)
      end

      ##
      # request send and waiting for an answer
      def ask(scope, name, element, vars)
        start_listening(scope, name)
        element, attributes = suggest_element(element, vars, name, scope)
        @cold_time = 0
        element, attributes = listening(element, attributes, vars, name, scope)
        @cold_time = nil
        name_from_app = get_from_app('locatine_name')
        name = name_from_app unless name_from_app.to_s.empty?
        response_action(element)
        { element: element, attributes: attributes, name: name }
      end
    end
  end
end
