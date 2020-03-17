# frozen_string_literal: true

module Locatine
  ##
  # Locatine single element
  #
  # It is used to store element info and to return parent.
  # I am thinking about moving staleness check here.
  class Element
    attr_accessor :answer

    ##
    # Init method
    #
    # @param session [Locatine::Session instance]
    # @param element_code [Hash] is an element hash returned by selenium,
    #   it is shaped like:
    #
    #   +{"element-6066-11e4-a52e-4f735466cecf"=>"c95a0580-4ac7-4c6d-..."}+
    def initialize(session, element_code)
      unless element_code
        raise ArgumentError, 'Cannot init element with no element data'
      end

      @session = session
      @answer = element_code
    end

    ##
    # Returning a parent element
    def parent
      parent = File.read("#{HOME}/scripts/parent.js")
      new_answer = @session.execute_script(parent, self)
      new_answer.nil? ? nil : Locatine::Element.new(@session, new_answer)
    end

    ##
    # Method to get the info about particular element or return it if it was
    # gathered before
    def info
      return @info if @info

      info = File.read("#{HOME}/scripts/element.js")
      @info = @session.execute_script(info, self)
      @info
    end

    ##
    # Method to get tag of the particular element or return it if it was
    # gathered before
    def tag_name
      return @tag if @tag

      script = 'return arguments[0].tagName'
      @tag = @session.execute_script(script, self)
      @tag
    end
  end
end
