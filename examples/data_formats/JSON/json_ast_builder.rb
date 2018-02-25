require_relative 'json_ast_nodes'

# The purpose of a JSONASTBuilder is to build piece by piece an AST
# (Abstract Syntax Tree) from a sequence of input tokens and
# visit events produced by walking over a GFGParsing object.
# Uses the Builder GoF pattern.
# The Builder pattern creates a complex object
# (say, a parse tree) from simpler objects (terminal and non-terminal
# nodes) and using a step by step approach.
class JSONASTBuilder < Rley::ParseRep::ParseTreeBuilder 
  Terminal2NodeClass = {
                         'false' => JSONBooleanNode,
                         'true' => JSONBooleanNode,
                         'null' => JSONNullNode,
                         'string' => JSONStringNode,
                         'number' => JSONNumberNode
                       }.freeze

  protected
  
  def terminal2node()
    Terminal2NodeClass
  end
  
  # Default class for representing terminal nodes.
  # @return [Class]
  def terminalnode_class()
    JSONTerminalNode
  end
  
  def reduce_JSON_text_0(_aProd, _range, _tokens, theChildren)
    return_first_child(_range, _tokens, theChildren)
  end
  
  # rule 'object' => %w[begin-object member-list end-object]
  def reduce_object_0(aProduction, _range, _tokens, theChildren)
    second_child = theChildren[1]
    second_child.symbol = aProduction.lhs
    return second_child
  end

  # rule 'object' => %w[begin-object end-object]
  def reduce_object_1(aProduction, _range, _tokens, _children)
    return JSONObjectNode.new(aProduction.lhs)
  end

  # rule 'member-list' => %w[member-list value-separator member]
  def reduce_member_list_0(_range, _tokens, theChildren)
    node = theChildren[0]
    node.members << theChildren.last
    return node
  end

  # rule 'member-list' => 'member'
  def reduce_member_list_1(aProduction, _range, _tokens, theChildren)
    node = JSONObjectNode.new(aProduction.lhs)
    node.members << theChildren[0]
    return node
  end

  # rule 'member' => %w[string name-separator value]
  def reduce_member_0(aProduction, _range, _tokens, theChildren)
    return JSONPair.new(theChildren[0], theChildren[2], aProduction.lhs)
  end

  # rule 'object' => %w[begin-object member-list end-object]
  def reduce_array_0(aProduction, _range, _tokens, theChildren)
    second_child = theChildren[1]
    second_child.symbol = aProduction.lhs
    return second_child  
  end

  # rule 'array' => %w[begin-array end-array]
  def reduce_array_1(_range, _tokens, _children)
    return JSONArrayNode.new
  end

  # rule 'array-items' => %w[array-items value-separator value]
  def reduce_array_items_0(_range, _tokens, theChildren)
    node = theChildren[0]
    node.children << theChildren[2]
    return node
  end
  
  #   rule 'array-items' => %w[value]
  def reduce_array_items_1(aProduction, _range, _tokens, theChildren)
    node = JSONArrayNode.new(aProduction.lhs)
    node.children << theChildren[0]
    return node
  end
end # class
# End of file
