$line_number = 0
$current_file = String.new

load "lexer.rb"
load "parser.rb"
load "evaluator.rb"

source = ARGV[0]

if !source
   puts "You need to give a file to process!"
   exit
end

if File.exists? source
   $current_file = source
   source = File.open(source, "r")
else
   puts "Unable to find file '#{source}'."
   exit
end
   
lines = File.readlines(source)
source.close

for string in lines
   $line_number += 1
   string = string.chomp

   string = eat_spaces(string)
   tokens   = make_tokens(string, true)
   next if !tokens  # For blank-lines.
   types  = infer_types(tokens, true)

   tokens = handle_comments(tokens, types)
   next if tokens.length == 0  # For comment-lines.
   tokens = tokens.join(" ")  # Join the array so now we can start with the real processing.

   tokens = make_tokens(tokens, false)
   types = infer_types(tokens, false)

   instruction = parse_tokens(tokens, types)
   evaluate(instruction)
end

p $variables
p $variable_type



