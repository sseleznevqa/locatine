# frozen_string_literal: true

module Locatine
  #
  # Locatine single element
  class Element
    attr_accessor :answer

    def initialize(session, element_code)
      unless element_code
        raise ArgumentError, 'Cannot init element with no element data'
      end

      @session = session
      @answer = element_code
    end

    def parent
      parent = File.read("#{HOME}/scripts/parent.js")
      new_answer = @session.execute_script(parent, self)
      new_answer.nil? ? nil : Locatine::Element.new(@session, new_answer)
    end

    def info
      return @info if @info

      info = File.read("#{HOME}/scripts/element.js")
      @info = @session.execute_script(info, self)
      @info
    end
  end
end
