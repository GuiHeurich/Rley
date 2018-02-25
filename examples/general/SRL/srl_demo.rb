require_relative './lib/tokenizer'
require_relative './lib/grammar'
require_relative './lib/ast_builder'

def print_title(aTitle)
  puts aTitle
  puts '=' * aTitle.size
end

def print_tree(aTitle, aParseTree)
  # Let's create a parse tree visitor
  visitor = Rley::ParseTreeVisitor.new(aParseTree)

  # Now output formatted parse tree
  print_title(aTitle)
  renderer = Rley::Formatter::Asciitree.new($stdout)
  renderer.render(visitor)
  puts ''
end

# Parse the input expression in command-line
if ARGV.empty?
  my_name = File.basename(__FILE__)
  msg = <<-END_MSG
WORK IN PROGRESS
Simple Regex Language parser:
- Parses a very limited subset of the language and displays the parse tree

Command-line syntax:
  ruby #{my_name} "SRL expression"
  where:
    the SRL expression is enclosed between double quotes (")

  Examples:
  ruby #{my_name} "letter from a to f exactly 4 times"
  ruby #{my_name} "uppercase letter between 2 and 3 times"
  ruby #{my_name} "digit from 0 to 7 once or more"
END_MSG
  puts msg
  exit(1)
end
puts ARGV[0]

# Create a Rley facade object
engine = Rley::Engine.new

########################################
# Step 1. Load a grammar for calculator
engine.use_grammar(SRL::Grammar)

lexer = SRL::Tokenizer.new(ARGV[0])
result = engine.parse(lexer.tokens)

unless result.success?
  # Stop if the parse failed...
  puts "Parsing of '#{ARGV[0]}' failed"
  puts "Reason: #{result.failure_reason.message}"
  exit(1)
end


# Generate a concrete syntax parse tree from the parse result
cst_ptree = engine.convert(result)
print_tree('Concrete Syntax Tree (CST)', cst_ptree)

# Generate an abstract syntax tree (AST) from the parse result
engine.configuration.repr_builder = ASTBuilder
ast_ptree = engine.convert(result)

# Now output the regexp literal
root = ast_ptree.root
print_title('SRL to Regexp representation:')
puts "#{ARGV[0]} => #{root.to_str}" # Output the expression result

# End of file
