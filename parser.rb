# coding: utf-8

class Declaration
   attr_accessor :ident, :rhs, :rhs_type
end

def check_for_redeclaration(ident)
   if $variables.keys.include? ident
      report_error("Redeclaration of identifier '#{ident}'.")
   end
end

def check_identifier(ident)
   if not $variables.keys.include? ident
      report_error("Undeclared identifier '#{ident}'.")
   end
end

def check_for_numbers(left, right, left_type, right_type, operator)
   operator = case operator
              when Token::TIMES
                 "*"
              when Token::DIVIDE
                 "/"
              when Token::PLUS
                 "+"
              when Token::MINUS
                 "-"
              end

   allowed = [Token::INT, Token::FLOAT, Token::IDENT, Token::ZERO]

   if not allowed.include? left_type
      report_error("Left token '#{left}' next to '#{operator}' is not of numeric type.")
   elsif not allowed.include? right_type
      report_error("Right token '#{right}' next to '#{operator}' is not of numeric type.")
   end

   if operator == "/"
      if right_type == Token::ZERO
         report_error("Dividing by zero.")
      end
   end

   # Reset the array to what types are allowed for identifiers.
   allowed = [Token::INT, Token::FLOAT, Token::ZERO]

   if left_type == Token::IDENT
      check_identifier(left)
      left_type = $variable_type[left]

      if not allowed.include? left_type
         report_error("Identfier '#{left}' is not of numeric type.")
      end
   end

   if right_type == Token::IDENT
      check_identifier(right)
      right_type = $variable_type[right]

      if operator == "/"
         if right_type == Token::ZERO
            report_error("Dividing by zero (identifier '#{right}' = 0).")
         end
      end

      if not allowed.include? right_type
         report_error("Identfier '#{right}' is not of numeric type.")
      end
   end
end

def check_for_abstinence(index, right, operator)
   operator = case operator
              when Token::TIMES
                 "*"
              when Token::DIVIDE
                 "/"
              when Token::PLUS
                 "+"
              when Token::MINUS
                 "-"
              end

   if index == 0
      report_error("Missing left token next to '#{operator}'.")
   elsif right == nil  
      # It's not Token::EOL since we passed 'right' and right is the token not the type (so it can't be Token::EOL).
      report_error("Missing right token next to '#{operator}'.")
   end
end

def parse_arithmetic(tokens, types)
   n = 0
   type = 0

   while type != Token::EOL
      type = types[n]
      token = tokens[n]

      left = tokens[n-1]
      right = tokens[n+1]

      left_type = types[n-1]
      right_type = types[n+1]

      # This case-when block checks for everything we need to make sure so that
      # we can safely apply methods on the types array to identify expressions.
      case type
      when Token::TIMES
         check_for_abstinence(n, right, Token::TIMES)
         check_for_numbers(left, right, left_type, right_type, Token::TIMES)
      when Token::DIVIDE
         check_for_abstinence(n, right, Token::DIVIDE)
         check_for_numbers(left, right, left_type, right_type, Token::DIVIDE)
      when Token::PLUS
         check_for_abstinence(n, right, Token::PLUS)
         check_for_numbers(left, right, left_type, right_type, Token::PLUS)
      when Token::MINUS
         check_for_abstinence(n, right, Token::MINUS)
         check_for_numbers(left, right, left_type, right_type, Token::MINUS)
      end

      n += 1
   end

   ops = [Token::TIMES, Token::DIVIDE, Token::PLUS, Token::MINUS]
   n = 0

   while n != Token::EOL
      type = types[n]
      
      if ops.include? type
         types[n-1..n+1] = Token::EXPRESSION
      else
         n += 1
      end
   end

   return tokens, types
end


def parse_structure(tokens, types)
   first  = types[0]
   second = types[1]
   third  = types[2]

   if first == Token::IDENT
      # For declarations.
      if second == Token::EQUALS
         allowed = [Token::ZERO, Token::INT, Token::FLOAT, Token::EXPRESSION, Token::IDENT, Token::STRING]

         if allowed.include? third
            if types[3] == Token::EOL  # Declaration-line only.
               decl = Declaration.new

               decl.ident = tokens[0]
               decl.rhs = tokens[2..tokens.length-1]
               decl.rhs_type = types[2]

               check_for_redeclaration(decl.ident)

               return decl
            end
         else
            report_error("Unknown type of rhs in declaration.")
         end
      else
         report_error("Expected '=' after identifier '#{tokens[0]}'.")
      end
   else
      report_error("First token has to be an identifier!")
   end

end

def parse_tokens(tokens, types)
   tokens, types = parse_arithmetic(tokens, types) 
   instruction   = parse_structure(tokens, types)
   
   return instruction
end

# def decl(line, types)
#    ident = line[0]

#    if types[1] == Token::EQUALS
#       String declaration.
#       if types[2] == Token::STRING
#          if $variables.keys.include? ident
#             report_error("Attempt to redeclare identifier '#{ident}'.")
#          else
#             if line[3] == nil
#                string_value = line[2][1..line[2].length-2]

#                $variables[ident] = string_value
#                $variable_type[ident] = Token::STRING
#             else
#                report_error("Unexpected token '#{line[3]}'.")
#             end
#          end
#       Declaration to zero.
#       elsif types[2] == Token::ZERO
#          if $variables.keys.include? ident
#             report_error("Attempt to redeclare identifier '#{ident}'.")
#          else
#             if line[3] == nil
#                int_value = 0

#                $variables[ident] = int_value
#                $variable_type[ident] = Token::ZERO
#             else
#                report_error("Unexpected token '#{line[3]}'.")
#             end
#          end
#       Integer declaration.
#       elsif types[2] == Token::INT
#          if $variables.keys.include? ident
#             report_error("Attempt to redeclare identifier '#{ident}'.")
#          else
#             if line[3] == nil
#                int_value = line[2].to_i

#                $variables[ident] = int_value
#                $variable_type[ident] = Token::INT
#             else
#                report_error("Unexpected token '#{line[3]}'.")
#             end
#          end
#       Float declaration.
#       elsif types[2] == Token::FLOAT
#          if $variables.keys.include? ident
#             report_error("Attempt to redeclare identifier '#{ident}'.")
#          else
#             if line[3] == nil
#                float_value = line[2].to_f

#                $variables[ident] = float_value
#                $variable_type[ident] = Token::FLOAT
#             else
#                report_error("Unexpected token '#{line[3]}'.")
#             end
#          end
         
#       Declarations based on other identifiers.
#       elsif types[2] == Token::IDENT
#          if $variables.keys.include? ident
#             report_error("Attempt to redeclare identifier '#{ident}'.")
#          else
#             if line[3] == nil
#                if $variables.keys.include? line[2]
#                   $variables[ident] = $variables[line[2]]
#                   $variable_type[ident] = $variable_type[line[2]]
#                else
#                   report_error("Undeclared identifier '#{line[2]}'.")
#                end
#             else
#                report_error("Unexpected token '#{line[3]}'.")
#             end
#          end
#       else
#          if line[2] == nil
#             report_error("Expected token after '='.")
#          else
#             report_error("For now, you can only assign a string or a numeric value to a variable.")
#          end
#       end
#    else
#       report_error("Expected '=' after identifier '#{ident}'.")
#    end
# end



