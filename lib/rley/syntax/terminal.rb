require_relative 'grm_symbol' # Load superclass

module Rley # This module is used as a namespace
  module Syntax # This module is used as a namespace
  
    # A terminal symbol represents a class of words in the language 
    # defined the grammar.
    class Terminal < GrmSymbol
      
      def initialize(aName)
        super(aName)
      end
    end # class
  
  end # module
end # module

# End of file