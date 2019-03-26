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
        ok = !element.stale? && element.exists?
        engine.execute_script(script, element) if ok
      rescue StandardError
        warn_cannot_highlight(element.selector)
      end

      ##
      # We can unhighlight an element
      def unhighlight(element)
        script = "arguments[0].removeAttribute('locatineclass')"
        ok = !element.stale? && element.exists?
        engine.execute_script(script, element) if ok
      rescue StandardError
        false
        # watir is not allowing to play with attributes of some elements
      end

      ##
      # We can highlight\unhighlight tons of elements at once
      def mass_highlight_turn(mass, turn_on = true)
        mass.each do |element|
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
