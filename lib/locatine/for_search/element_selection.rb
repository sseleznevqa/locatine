module Locatine
  module ForSearch
    ##
    # Cooking element data for dialog
    module ElementSelection
      private

      def add_selected_attributes(new_attributes, attributes)
        if get_from_app('locatinecollection') == 'true'
          get_commons(new_attributes, attributes.to_h)
        else
          new_attributes
        end
      end

      def selected_element_attributes(tag, index, vars)
        element = engine.elements(tag_name: tag)[index]
        attrs = generate_data([element], vars).to_h
        old_depth = @depth
        while find_by_data(attrs, vars).length > 1
          @depth += 1
          attrs = get_family_info(element, vars).to_h
          # scope spec is sad!!!
          break if attrs.length < @depth
        end
        warn_totally_same(@depth) unless old_depth == @depth
        @depth = old_depth
        attrs
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
    end
  end
end
