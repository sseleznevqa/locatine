require 'watir'
require 'json'
require 'fileutils'
require 'chromedriver-helper'

# Internal requires
require 'locatine/merge'
require 'locatine/public'
require 'locatine/helpers'
require 'locatine/file_work'
require 'locatine/highlight'
require 'locatine/data_logic'
require 'locatine/find_logic'
require 'locatine/find_by_css'
require 'locatine/dialog_logic'
require 'locatine/find_by_magic'
require 'locatine/find_by_guess'
require 'locatine/data_generate'
require 'locatine/dialog_actions'
require 'locatine/xpath_generator'
require 'locatine/find_by_locator'

module Locatine
  ##
  # Search is the main class of the Locatine
  #
  # Locatine can search.
  class Search
    include Locatine::Merge
    include Locatine::Public
    include Locatine::Helpers
    include Locatine::FileWork
    include Locatine::DataLogic
    include Locatine::FindLogic
    include Locatine::Highlight
    include Locatine::FindByCss
    include Locatine::FindByMagic
    include Locatine::DialogLogic
    include Locatine::FindByGuess
    include Locatine::DataGenerate
    include Locatine::FindByLocator
    include Locatine::DialogActions
    include Locatine::XpathGenerator

    attr_accessor :data,
                  :depth,
                  :learn,
                  :stability_limit,
                  :scope,
                  :tolerance,
                  :visual_search
    attr_reader   :json,
                  :browser
  end
end
