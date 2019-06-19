require 'watir'
require 'json'
require 'fileutils'
require 'webdrivers'

# Internal requires
require 'locatine/for_search/merge'
require 'locatine/for_search/public'
require 'locatine/for_search/saying'
require 'locatine/for_search/helpers'
require 'locatine/for_search/defaults'
require 'locatine/for_search/file_work'
require 'locatine/for_search/listening'
require 'locatine/for_search/highlight'
require 'locatine/for_search/data_logic'
require 'locatine/for_search/find_logic'
require 'locatine/for_search/find_by_css'
require 'locatine/for_search/name_helper'
require 'locatine/for_search/dialog_logic'
require 'locatine/for_search/find_by_magic'
require 'locatine/for_search/find_by_guess'
require 'locatine/for_search/data_generate'
require 'locatine/for_search/xpath_generator'
require 'locatine/for_search/find_by_locator'
require 'locatine/for_search/element_selection'

module Locatine
  ##
  # Search is the main class of the Locatine
  #
  # Locatine can search.
  class Search
    include Locatine::ForSearch::Merge
    include Locatine::ForSearch::Public
    include Locatine::ForSearch::Saying
    include Locatine::ForSearch::Helpers
    include Locatine::ForSearch::Defaults
    include Locatine::ForSearch::FileWork
    include Locatine::ForSearch::DataLogic
    include Locatine::ForSearch::Listening
    include Locatine::ForSearch::FindLogic
    include Locatine::ForSearch::Highlight
    include Locatine::ForSearch::FindByCss
    include Locatine::ForSearch::NameHelper
    include Locatine::ForSearch::FindByMagic
    include Locatine::ForSearch::DialogLogic
    include Locatine::ForSearch::FindByGuess
    include Locatine::ForSearch::DataGenerate
    include Locatine::ForSearch::FindByLocator
    include Locatine::ForSearch::XpathGenerator
    include Locatine::ForSearch::ElementSelection

    attr_accessor :data,
                  :depth,
                  :learn,
                  :stability_limit,
                  :scope,
                  :tolerance,
                  :visual_search,
                  :no_fail,
                  :trusted,
                  :untrusted,
                  :autolearn
    attr_reader   :json,
                  :browser
  end
end
