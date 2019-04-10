module Locatine
  module ForSearch
    ##
    # Locatine can highlight elements
    module Highlight
      private

      ##
      # We can highlight an element
      def highlight(element)
        script = "arguments[0].setAttribute('locatineclass','foundbylocatine')"
        engine.execute_script(script, element)
      rescue StandardError
        warn_cannot_highlight(element.selector)
      end

      ##
      # We can unhighlight an element
      def unhighlight(element)
        script = "arguments[0].removeAttribute('locatineclass')"
        engine.execute_script(script, element)
      rescue StandardError
        false
        # watir is not allowing to play with attributes of some elements
      end

      ##
      # We can highlight\unhighlight tons of elements at once
      def mass_highlight_turn(mass, turn_on = true)
        warn_much_highlight if turn_on && mass.length > 50
        mass[0..49].each do |element|
          if turn_on
            highlight element
          else
            unhighlight element
          end
        end
      end
    end
  end
end
