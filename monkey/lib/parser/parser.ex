defmodule Parser do
  alias Ast.Program

  @lowest 0
  @equals 1
  @ltgt 2
  @sum 3
  @product 4
  @prefix 5
  @call 6
  @index 7
  @precedence %{
    :eq => @equals,
    :not_eq => @equals,
    :lt => @ltgt,
    :gt => @ltgt,
    :plus => @sum,
    :minus => @sum,
    :slash => @product,
    :asterisk => @product,
    :lparen => @call,
    :lbracket => @index
  }

  @prefix_tokens [:bang, :minus]
  @infix_tokens [:plus, :minus, :slash, :asterisk, :eq, :not_eq, :lt, :gt, :lparen]

  def parse(tokens) do
    {statements, _rest, errors} = parse_statements(tokens, [], [])
    {%Program{statements: statements}, errors}
  end

  defp parse_statements([], statements, errors) do
    {statements, [], errors}
  end

  defp parse_statements([{:eof, ""}], statements, errors) do
    {statements, [], errors}
  end

  defp parse_statements([{:rbrace, "}"} | rest], statements, errors) do
    {statements, rest, errors}
  end

  defp parse_statements([token | rest], statements, errors) do
    {{stmt, rest, errors}, more} =
      case token do
        {:let, "let"} ->
          {errors, _} = check_error(rest, {:identifier, "IDENT"}, errors)
          {parse_let_statement(rest, %Ast.LetStatement{token: {:let, "let"}}, errors), true}

        {:return, "return"} ->
          {parse_return_statement(rest, %Ast.ReturnStatement{token: {:return, "return"}}, errors),
           true}

        _ ->
          {parse_expression_statement([token | rest], errors), false}
      end

    if more do
      parse_statements(rest, statements ++ [stmt], errors)
    else
      {statements ++ [stmt], rest, errors}
    end
  end

  defp parse_call_arguments([{:rparen, ")"} | rest], arguments, errors, _left) do
    {arguments, rest, errors}
  end

  defp parse_call_arguments([{:comma, ","} | rest], arguments, errors, left) do
    parse_call_arguments(rest, arguments, errors, left)
  end

  defp parse_call_arguments(tokens, arguments, errors, left) do
    {left, tokens, errors} = parse_expression(@lowest, tokens, errors, left)
    parse_call_arguments(tokens, arguments ++ [left], errors, nil)
  end

  defp check_error(tokens, {expected, literal}, errors) do
    [{next_token, _} | rest] = tokens

    if next_token != expected do
      {errors ++ ["expected next token to be #{literal}, got #{next_token} instead"], rest}
    else
      {errors, rest}
    end
  end

  defp parse_let_statement([{:identifier, x} | rest], let, errors) do
    identifier = %Ast.Identifier{token: {:identifier, x}, value: x}
    {errors, rest} = check_error(rest, {:assign, "="}, errors)
    parse_let_statement(rest, %{let | name: identifier}, errors)
  end

  defp parse_let_statement([{:semicolon, ";"} | rest], let, errors), do: {let, rest, errors}

  defp parse_let_statement([_exprssion | rest], let, errors),
    do: parse_let_statement(rest, let, errors)

  defp parse_let_statement([], let, errors), do: {let, [], errors}

  defp parse_return_statement([{:semicolon, ";"} | rest], return, errors),
    do: {return, rest, errors}

  defp parse_return_statement([_expression | rest], return, errors),
    do: parse_return_statement(rest, return, errors)

  defp parse_expression_statement(tokens, errors) do
    {expression, rest, errors} = parse_expression(@lowest, tokens, errors, nil)

    {%Ast.ExpressionStatement{
       token: expression.token,
       expression: expression
     }, rest, errors}
  end

  defp parse_infix_expression(precedence, [{token, operator} | rest], errors, left)
       when token in @infix_tokens do
    {left, rest, errors} =
      case token do
        :lparen ->
          {arguments, rest, errors} = parse_call_arguments(rest, [], errors, nil)

          {%Ast.CallExpression{
             token: {token, operator},
             function: left,
             arguments: arguments
           }, rest, errors}

        _ ->
          next_precedence = next_precedence([{token, operator}])
          {right, rest, errors} = parse_expression(next_precedence, rest, errors, left)

          {%Ast.InfixExpression{
             token: {token, operator},
             left: left,
             operator: operator,
             right: right
           }, rest, errors}
      end

    process_precedence(precedence, rest, errors, left)
  end

  defp parse_expression(precedence, [{token, operator} | rest], errors, left)
       when token in @prefix_tokens do
    {right, rest, errors} = parse_expression(@prefix, rest, errors, left)

    left = %Ast.PrefixExpression{
      token: {token, operator},
      operator: operator,
      right: right
    }

    process_precedence(precedence, rest, errors, left)
  end

  defp parse_expression(precedence, [token | rest], errors, left) do
    {left, rest, errors} =
      case token do
        {:identifier, x} ->
          {%Ast.Identifier{token: token, value: x}, rest, errors}

        {:int, x} ->
          {%Ast.IntegerLiteral{token: token, value: String.to_integer(x)}, rest, errors}

        {:t, _} ->
          {%Ast.Boolean{token: token, value: true}, rest, errors}

        {:f, _} ->
          {%Ast.Boolean{token: token, value: false}, rest, errors}

        {:lparen, "("} ->
          {left, rest, errors} = parse_expression(@lowest, rest, errors, left)
          {left, tl(rest), errors}

        {:if, "if"} ->
          {condition, rest, errors} = parse_expression(@lowest, rest, errors, left)
          {if_true, rest, errors} = parse_block_statement(tl(rest), errors)
          [next_token | else_rest] = tl(rest)

          {if_false, rest, errors} =
            if next_token == {:else, "else"} do
              parse_block_statement(tl(else_rest), errors)
            else
              {nil, rest, errors}
            end

          exp = %Ast.IfExpression{
            token: token,
            condition: condition,
            if_true: if_true,
            if_false: if_false
          }

          {exp, rest, errors}

        {:function, "fn"} ->
          {parameters, rest, errors} = parse_function_parameters(tl(rest), errors, [])

          {body, rest, errors} = parse_block_statement(tl(rest), errors)

          {%Ast.FunctionLiteral{
             token: {:function, "fn"},
             parameters: parameters,
             body: body
           }, rest, errors}
      end

    process_precedence(precedence, rest, errors, left)
  end

  defp parse_block_statement(tokens, errors) do
    {statements, rest, errors} = parse_statements(tokens, [], errors)

    {%Ast.BlockStatement{
       token: {:lbrace, "{"},
       statements: statements
     }, rest, errors}
  end

  defp parse_function_parameters([{:rparen, ")"} | rest], errors, parameters),
    do: {parameters, rest, errors}

  defp parse_function_parameters([{:comma, ","} | rest], errors, parameters),
    do: parse_function_parameters(rest, errors, parameters)

  defp parse_function_parameters([token | rest], errors, parameters) do
    {_, value} = token

    id = %Ast.Identifier{
      token: token,
      value: value
    }

    parse_function_parameters(rest, errors, parameters ++ [id])
  end

  defp next_precedence(tokens) do
    {next_token, _token} = hd(tokens)
    Map.get(@precedence, next_token, @lowest)
  end

  defp process_precedence(precedence, tokens, errors, left) do
    if precedence < next_precedence(tokens) do
      parse_infix_expression(precedence, tokens, errors, left)
    else
      {left, tokens, errors}
    end
  end
end
