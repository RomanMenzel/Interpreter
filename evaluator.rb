def do_arithmetic_low_precedence(rhs)
   n = 0

   for token in rhs
      if token == "+"
         # @Speed @Speed @Speed @Speed @Speed @Speed @Speed @Speed
         rhs[n-1] = $variables[rhs[n-1]] if $variables.keys.include? rhs[n-1]
         rhs[n+1] = $variables[rhs[n+1]] if $variables.keys.include? rhs[n+1]

         rhs[n-1..n+1] = (rhs[n-1].to_f + rhs[n+1].to_f).to_s
         return rhs, true
      elsif token == "-"
         # @Speed @Speed @Speed @Speed @Speed @Speed @Speed @Speed
         rhs[n-1] = $variables[rhs[n-1]] if $variables.keys.include? rhs[n-1]
         rhs[n+1] = $variables[rhs[n+1]] if $variables.keys.include? rhs[n+1]

         rhs[n-1..n+1] = (rhs[n-1].to_f - rhs[n+1].to_f).to_s
         return rhs, true
      end

      n += 1
   end

   return rhs, false
end

def do_arithmetic_high_precedence(rhs)
   n = 0

   for token in rhs
      if token == "*"
         # @Speed @Speed @Speed @Speed @Speed @Speed @Speed @Speed
         rhs[n-1] = $variables[rhs[n-1]] if $variables.keys.include? rhs[n-1]
         rhs[n+1] = $variables[rhs[n+1]] if $variables.keys.include? rhs[n+1]

         rhs[n-1..n+1] = (rhs[n-1].to_f * rhs[n+1].to_f).to_s
         return rhs, true
      elsif token == "/"
         # @Speed @Speed @Speed @Speed @Speed @Speed @Speed @Speed
         rhs[n-1] = $variables[rhs[n-1]] if $variables.keys.include? rhs[n-1]
         rhs[n+1] = $variables[rhs[n+1]] if $variables.keys.include? rhs[n+1]

         rhs[n-1..n+1] = (rhs[n-1].to_f / rhs[n+1].to_f).to_s
         return rhs, true
      end

      n += 1
   end

   return rhs, false
end

def do_calculations(rhs)
   changed = true
   
   # High precedence artithmetic calculations.
   while true
      rhs, changed = do_arithmetic_high_precedence(rhs)
      break if !changed
   end

   changed = true

   # Low precedence artithmetic calculations.
   while true
      rhs, changed = do_arithmetic_low_precedence(rhs)
      break if !changed
   end

   return rhs
end

def evaluate(instruction)
   if instruction.is_a? Declaration
      decl = Declaration.new

      decl.ident = instruction.ident
      decl.rhs = instruction.rhs
      decl.rhs_type = instruction.rhs_type

      # Right-hand side is an expression.
      if decl.rhs_type == Token::EXPRESSION
         rhs = do_calculations(decl.rhs)
         $variables[decl.ident] = decl.rhs[0].to_f
         $variable_type[decl.ident] = Token::FLOAT
         
      # Right-hand side is an int.
      elsif decl.rhs_type == Token::INT
         $variables[decl.ident] = decl.rhs[0].to_i
         $variable_type[decl.ident] = Token::INT
         
      # Right-hand side is a float.
      elsif decl.rhs_type == Token::FLOAT
         $variables[decl.ident] = decl.rhs[0].to_f
         $variable_type[decl.ident] = Token::FLOAT
         
      # Right-hand side is zero.
      elsif decl.rhs_type == Token::ZERO
         $variables[decl.ident] = 0 
         $variable_type[decl.ident] = Token::ZERO

      # Right-hand side is an identifier.         
      elsif decl.rhs_type == Token::IDENT
         check_identifier(decl.rhs[0])

         $variables[decl.ident] = $variables[decl.rhs[0]] 
         $variable_type[decl.ident] = $variable_type[decl.rhs[0]]
         
      # Right-hand side is a string.
      elsif decl.rhs_type == Token::STRING
         $variables[decl.ident] = decl.rhs[0].to_s
         $variable_type[decl.ident] = Token::STRING
      end
   end
end
