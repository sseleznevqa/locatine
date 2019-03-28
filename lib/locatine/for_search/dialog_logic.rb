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
        send_working(tag, index)
        element, new_attributes = selected_element(tag, index, vars, attributes)
        warn_dropping(tag, index) unless element

        warn_type(tag) if @type && !element

        return_selected(element, attributes, new_attributes, vars)
      end

      def return_old_selection(attrs, vars)
        return find_by_data(attrs, vars).to_a, attrss.to_h if attrs.to_h != {}

        return nil, {}
      end

      def return_selected(element, attributes, new_attributes, vars)
        if !element && new_attributes.to_h != {}
          send_lost
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
          found = find_in_data(attributes)
          mass_highlight_turn(element)
          send_selected(element.length, name, scope) unless found
          send_same_entry(element.length, name, scope, found) if found
        end
        return element, attributes
      end

      def send_same_entry(length, name, scope, found)
        push_title "#{length} #{verb(length)} selected as #{name} in #{scope}."\
        " But it was already defined #{found.length} times."
        example = found.sample
        send_to_app('locatinehint', "For example like #{example[:name]} in"\
        " #{example[:scope]}")
      end

      # TODO More todo
      def find_in_data(attributes)
        found = []
        @data.each_pair do |scope, elements|
          elements.each_pair do |element, hash|
            good = true
            hash.each_pair do |depth, array|
              trusted = get_trusted(array).map do |i|
                i.reject { |k| k == 'stability' }
              end
              good = good && (trusted - attributes[depth] == [])
            end
            found.push(scope: scope, name: element) if good
          end
        end
        found.empty? ? nil : found
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
          els, attrs = what_was_selected(els, attrs, vars, name, scope)
        when 'declined'
          els, attrs = decline(els, name, scope)
        end
        return els, attrs
      end

      def listening(els, attrs, vars, name, scope)
        until get_from_app('locatineconfirmed') == 'true'
          sleep(0.1)
          els, attrs = user_selection(els, attrs, vars, name, scope)
        end
        return els, attrs if els

        decline(els, name, scope)
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
        response_action(element)
        return element, attributes
      end
    end
  end
end
