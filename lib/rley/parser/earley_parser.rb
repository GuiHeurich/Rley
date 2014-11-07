require_relative '../syntax/grammar'
require_relative 'dotted_item'

module Rley # This module is used as a namespace
  module Parser # This module is used as a namespace
  
    # Implementation of a parser that uses the Earley parsing algorithm.
    class EarleyParser
      # The grammar of the language.
      attr_reader(:grammar)
      
      # The dotted items for the productions of the grammar
      attr_reader(:dotted_items)
      
      
      def initialize(aGrammar)
        @grammar = aGrammar
        @dotted_items = build_dotted_items(aGrammar)
      end
      
      private
      
      def build_dotted_items(aGrammar)
        items = []
        aGrammar.rules.each do |prod|
          rhs_size = prod.rhs.size
          if rhs_size == 0
            items << DottemItem.new(prod, 0)
          else
            items += (0..rhs_size).map { |i| DottedItem.new(prod, i) }
          end
        end
        
        return items
      end
    end # class
  
  end # module
end # module

# End of file