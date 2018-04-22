$variables = Hash.new     # This hash stores the name and value of the variables.
$variable_type = Hash.new # This hash stores the name and the type of the variables.

$tab = "\011"

def report_error(string)
   puts "\n#{$current_file}:#{$line_number}: Error: #{string}"
   puts
   exit
end

module Token
   UNKNOWN       = 0

   STRING        = 1
   INT           = 2
   FLOAT         = 3
   IDENT         = 4

   OPEN_PAREN    = 5
   CLOSED_PAREN  = 6

   EQUALS        = 7

   PLUS          = 8
   TIMES         = 9
   DIVIDE        = 10
   MINUS         = 11

   ZERO          = 12
   FIRST_IS_ZERO = 13

   COMMA         = 14
   DOT           = 15

   EOL           = 16

   EXPRESSION    = 17
end

def handle_comments(line, types)
   n = 0

   for token in line
      t = types[n]

      if t == Token::DIVIDE
         if n == 0 and types[1] == Token::DIVIDE
            line = line.clear
            break
         end

         if types[n+1] == Token::DIVIDE
            line = line[0..n-1] 
            break
         end
      end

      n += 1         
   end

   return line
end

def only_ident_chars(string)
   result = false
   n = 0

   string.each_char do |char|
      if ('a'..'z').include? char
         n += 1
      elsif ('A'..'Z').include? char
         n += 1
      elsif char == "_"
         n += 1
      elsif (1..9).include? char.to_i
         n += 1
      elsif char == "0"
         n += 1
      else
         break
      end
   end

   if n == string.length
      result = true
   end
   
   return result, n
end

def is_ident_char(char)
   return true if char == "_"
   return true if ('a'..'z').include? char
   return true if ('A'..'Z').include? char

   return false
end

def only_digits(string)
   dot = false
   result = false

   n = 0

   string.each_char do |char|
      if (1..9).include? char.to_i
         n += 1
      elsif char == "0"  # Zero has to be checked seperatly from the above since char.to_i also returns 0 if it's not a digit.
         n += 1
      else
         break
      end
   end

   if n == string.length
      result = true
   end
   
   return result, n
end


def eat_spaces(string)
   n = 0

   # Remove the spaces at the front.
   string.each_char do |char|
      if char != " " and char != $tab
         break 
      end
      n += 1 
   end

   string = string[n..string.length-1]
   string = string.reverse

   # Remove the spaces at the end.
   n = 0
   string.each_char do |char|
      if char != " " and char != $tab
         break 
      end
      n += 1 
   end

   string = string[n..string.length-1]
   return string.reverse
end

def make_tokens(string, handling_comments)
   token = ""
   tokens = []

   space = false
   quote = false

   token_new = ["(", ")", "=", "+", "*", "/", "-", ",", "."] 

   string.each_char do |char|
      # 
      # Double-Quote handling for strings.
      # 

      # Ending of a string.
      if char == "\"" and quote == true
         token += char 
         tokens.push(token)

         token = ""
         quote = false
         next
      end
      
      # Here, we are in a string.
      if quote == true
         token += char
         next
      end

      # This is the beginning of a new string.
      if char == "\""
         tokens.push(token) unless token == ""

         quote = true
         token = ""

         token += char
         next
      end

      #
      # Handling spaces between tokens.
      #

      if (char == " " or char == $tab) and space == true 
         next
      elsif char == " " or char == $tab
         space = true
         tokens.push(token) unless token == ""
         
         token = ""
      else
         if token_new.include? char  # For one-character tokens.
            tokens.push(token) unless token == ""
            tokens.push(char)
            token = ""
         else
            token += char
            space = false
         end
      end
   end

   # If quote is still true we haven't got another double quote but there has once been one.
   if quote == true
      if !handling_comments
         report_error("Unexpected end of line while creating string token.")
      end
   end

   # This is important because we also have to create a new token even if there weren't any token-seperaters.
   tokens.push(token) unless token == ""

   if tokens.length == 0
      return false
   else
      return tokens
   end
end

def handle_floats(types, tokens)
   n = 0
   
   for type in types
      if type == Token::DOT
         right = types[n+1]

         if right == Token::INT or right == Token::FIRST_IS_ZERO or right == Token::ZERO
            left = types[n-1]
            
            if left == Token::INT or left == Token::ZERO
               float_token = tokens[n-1] + "." + tokens[n+1]

               tokens[n-1..n+1] = float_token  # Replace the old three entries with the new float token itself.
               types[n-1..n+1]  = Token::FLOAT # And replace the old three entries in here with just one float type.
            elsif left == nil
               report_error("Missing token before '.'.")
            else
               report_error("Invalid token '#{tokens[n-1]}' before '.'.")
            end
         elsif right == nil
            report_error("Missing token after '.'.")
         else
            report_error("Invalid token '#{tokens[n-1]}' after '.'.")
         end
      end

      n += 1

   end

   return types, tokens
end

def infer_types(tokens, handling_comments)
   types = Array.new(tokens.length)
   n = 0

   for token in tokens
      first = token[0]

      if first == "\""
         types[n] = Token::STRING


      #
      # Single-character tokens.
      #

      elsif first == "("
         types[n] = Token::OPEN_PAREN
      elsif first == ")"
         types[n] = Token::CLOSED_PAREN

      elsif first == "="
         types[n] = Token::EQUALS

      elsif first == "+"
         types[n] = Token::PLUS
      elsif first == "-"
         types[n] = Token::MINUS
      elsif first == "*"
         types[n] = Token::TIMES
      elsif first == "/"
         types[n] = Token::DIVIDE

      elsif first == ","
         types[n] = Token::COMMA
      elsif first == "."
         types[n] = Token::DOT

      elsif token == "0"
         types[n] = Token::ZERO

      # 
      # Numbers.
      #

      elsif (1..9).include? first.to_i
         result, place = only_digits(token[1..token.length-1])

         if result == true
            types[n] = Token::INT
         else
            if !handling_comments
               report_error("Invalid character '#{token[place+1]}' in integer token.")
            end
         end
      elsif first == "0" 
         result, place = only_digits(token[1..token.length-1])

         if result == true
            types[n] = Token::FIRST_IS_ZERO
         else
            if !handling_comments
               report_error("Invalid character '#{token[place+1]}' in integer token.")
            end
         end
      elsif is_ident_char(first)
         result, place = only_ident_chars(token[1..token.length-1])

         if result == true
            types[n] = Token::IDENT
         else
            if !handling_comments
               report_error("Invalid character '#{token[place+1]}' in identifier token.")
            end
         end
      else         
         types[n] = Token::UNKNOWN
      end

      n += 1
   end

   if !handling_comments
      types, tokens = handle_floats(types, tokens)
   end

   # Adding Token::EOL at the end of the array.
   types[types.length] = Token::EOL

   return types
end
