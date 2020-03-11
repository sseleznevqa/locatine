# frozen_string_literal: true

module Locatine
  ##
  # Simple error
  class Error
    attr_accessor :answer, :status

    def initialize(response)
      @answer = response.body
      @status = response.code
    end
  end
end
