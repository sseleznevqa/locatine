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

      def simple_attrs(tag, index, vars)
        element = engine.elements(tag_name: tag)[index]
        attrs = generate_data([element], vars).to_h
        return element, attrs
      end

      def negative_need(element, vars, old_depth)
        @depth = old_depth
        warn_no_negatives
        generate_data([element], vars).to_h
      end

      def complex_attrs(element, vars, old_depth = @depth)
        attrs = get_family_info(element, vars).to_h
        return negative_need(element, vars, old_depth) if attrs.length < @depth

        if find_by_data(attrs, vars).length > 1
          @depth += 1
          return complex_attrs(element, vars, old_depth)
        end
        @depth = old_depth
        attrs
      end

      def selected_element_attributes(tag, index, vars)
        element, attrs = simple_attrs(tag, index, vars)
        length = find_by_data(attrs, vars).to_a.length
        attrs = complex_attrs(element, vars) if length > 1
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
