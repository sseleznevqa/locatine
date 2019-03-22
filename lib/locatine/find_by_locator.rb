module Locatine
  ##
  # Methods related to the most simple search by ready locator.
  module FindByLocator
    private

    def collection?(the_class)
      case the_class.superclass.to_s
      when 'Watir::Element'
        false
      when 'Watir::ElementCollection'
        true
      else
        collection?(the_class.superclass)
      end
    end

    ##
    # Getting all the elements matching a locator
    def find_by_locator(locator)
      method = @type.nil? ? :elements : @type
      results = engine.send(method, locator)
      return correct_method_detected(results) if collection?(results.class)

      return acceptable_method_detected(results, method, locator)
    end

    def correct_method_detected(results)
      all = []
      begin
        results[0].wait_until(timeout: @cold_time, &:present?)
      rescue StandardError
        nil
      end
      results.each { |item| all.push item if item.present? }
      return all unless all.empty?
      return nil if all.empty?
    end

    def acceptable_method_detected(results, method, locator)
      warn "#{method} works for :look_in. But it is better to use a method of"\
      ' Watir::Browser that returns a collection (like :divs, :links, etc.)'
      the_class = results.class
      results = engine.elements(locator)
                      .to_a.select { |item| item.to_subtype.class == the_class }
      correct_method_detected(results)
    end

    ##
    # Getting elements by tag
    def find_by_tag(hash, vars, depth = 0)
      correction = '//*' if depth.to_i > 0
      xpath = "//*[self::#{process_string(hash['value'], vars)}]"
      find_by_locator(xpath: "#{xpath}#{correction}#{not_magic_div}")
    end

    ##
    # Getting elements by text
    def find_by_text(hash, vars, depth = 0)
      correction = '//*' if depth.to_i > 0
      xpath = "//*[contains(text(), '#{process_string(hash['value'], vars)}')]"
      find_by_locator(xpath: "#{xpath}#{correction}#{not_magic_div}")
    end

    ##
    # Getting elements by attribute
    def find_by_attribute(hash, vars, depth = 0)
      correction = '//*' if depth.to_i > 0
      full_part = '//*[@*'
      hash['name'].split('_').each do |part|
        full_part += "[contains(name(), '#{part}')]"
      end
      value = process_string(hash['value'], vars)
      xpath = full_part + "[contains(., '#{value}')]]"
      find_by_locator(xpath: "#{xpath}#{correction}#{not_magic_div}")
    end

    ##
    # Getting all the elements via stored information
    def find_by_data(data, vars)
      find_by_locator(xpath: generate_xpath(data, vars))
    end
  end
end
