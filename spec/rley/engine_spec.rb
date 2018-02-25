require_relative '../spec_helper'


require_relative '../../lib/rley/lexical/token'
require_relative '../../lib/rley/parse_rep/cst_builder'
require_relative '../../lib/rley/parse_tree_visitor'

# Load the class under test
require_relative '../../lib/rley/engine'

module Rley # Open this namespace to avoid module qualifier prefixes
  describe Engine do
    subject { Engine.new }

    context 'Creation and initialization:' do
      it 'could be created without argument' do
        expect { Engine.new }.not_to raise_error
      end

      it 'could be created with block argument' do
        expect { Engine.new do |config|
            config.parse_repr = :raw
          end
        }.not_to raise_error
      end

      it "shouldn't have a link to a grammar yet" do
        expect(subject.grammar).to be_nil
      end
    end # context

    context 'Grammar building:' do
      it 'should build grammar' do
        subject.build_grammar do
          add_terminals('a', 'b', 'c')
          add_production('S' => ['A'])
          add_production('A' => %w[a A c])
          add_production('A' => ['b'])
        end

        expect(subject.grammar).to be_kind_of(Rley::Syntax::Grammar)
        expect(subject.grammar.rules.size).to eq(3)
      end
    end # context

    class ABCTokenizer
      # Constructor
      def initialize(someText)
        @input = someText.dup
      end

      def each()
        lexemes = @input.scan(/\S/)
        lexemes.each do |ch|
          if ch =~ /[abc]/
            yield Rley::Lexical::Token.new(ch, ch)
          else
             raise StandardError, "Invalid character #{ch}"
          end
        end
      end
    end # class

    # Utility method. Ensure that the engine
    # has the defnition of a sample grammar
    def add_sample_grammar(anEngine)
      anEngine.build_grammar do
        add_terminals('a', 'b', 'c')
        add_production('S' => ['A'])
        add_production('A' => %w[a A c])
        add_production('A' => ['b'])
      end
    end

    context 'Parsing:' do
      subject do
        instance = Engine.new
        add_sample_grammar(instance)
        instance
      end

      it 'should parse a stream of tokens' do
        sample_text = 'a a b c c'
        tokenizer = ABCTokenizer.new(sample_text)
        result = subject.parse(tokenizer)
        expect(result).to be_success
      end
    end # context



    context 'Parse tree manipulation:' do
      subject do
        instance = Engine.new
        add_sample_grammar(instance)
        instance
      end
      
      let(:sample_tokenizer) do
        sample_text = 'a a b c c'
        ABCTokenizer.new(sample_text)      
      end

      it 'should build default parse trees' do
        raw_result = subject.parse(sample_tokenizer)
        ptree = subject.convert(raw_result)
        expect(ptree).to be_kind_of(PTree::ParseTree)
      end

      it 'should build custom parse trees' do
        # Cheating: we point to default tree builder (CST)
        subject.configuration.repr_builder = ParseRep::CSTBuilder        
        raw_result = subject.parse(sample_tokenizer)
        ptree = subject.convert(raw_result)
        expect(ptree).to be_kind_of(PTree::ParseTree)
      end
      
      it 'should provide a parse visitor' do
        raw_result = subject.parse(sample_tokenizer)
        ptree = subject.to_ptree(raw_result)
        visitor = subject.ptree_visitor(ptree)
        expect(visitor).to be_kind_of(ParseTreeVisitor)
      end    
    end # context
  end # describe
end # module

