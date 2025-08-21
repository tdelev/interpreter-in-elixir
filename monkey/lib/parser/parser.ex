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

  @infix_tokens [:plus, :minus, :slash, :asterisk, :eq, :not_eq, :lt, :gt]

  def parse(tokens) do
    parse_program(tokens, %Program{statements: []}, [])
  end

  defp parse_program([], program, errors) do
    {program, errors}
  end

  defp parse_program([{:eof, ""}], program, errors) do
    {program, errors}
  end

  defp parse_program([{:let, "let"} | rest], program, errors) do
    {errors, _} = check_error(rest, {:identifier, "IDENT"}, errors)
    {stmt, rest, errors} = parse_let_statement(rest, %Ast.LetStatement{token: :let}, errors)
    program = %{program | statements: program.statements ++ [stmt]}
    parse_program(rest, program, errors)
  end

  defp parse_program([{:return, "return"} | rest], program, errors) do
    {let, rest, errors} =
      parse_return_statement(rest, %Ast.ReturnStatement{token: :return}, errors)

    program = %{program | statements: program.statements ++ [let]}
    parse_program(rest, program, errors)
  end

  defp parse_program(tokens, program, errors) do
    {e, _rest, errors} = parse_expression_statement(tokens, errors)

    program = %{program | statements: program.statements ++ [e]}
    {program, errors}
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
    identifier = %Ast.Identifier{token: :identifier, value: x}
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
    next_precedence = next_precedence([{token, operator}])
    {right, rest, errors} = parse_expression(next_precedence, rest, errors, left)

    left = %Ast.InfixExpression{
      token: token,
      left: left,
      operator: operator,
      right: right
    }

    process_precedence(precedence, rest, errors, left)
  end

  defp parse_expression(precedence, [{:identifier, x} | rest], errors, _left) do
    left = %Ast.Identifier{token: :identifier, value: x}
    process_precedence(precedence, rest, errors, left)
  end

  defp parse_expression(precedence, [{:int, x} | rest], errors, _left) do
    left = %Ast.IntegerLiteral{token: :int, value: String.to_integer(x)}
    process_precedence(precedence, rest, errors, left)
  end

  defp parse_expression(precedence, [{:bang, "!"} | rest], errors, left) do
    {right, rest, errors} = parse_expression(@prefix, rest, errors, left)

    left = %Ast.PrefixExpression{
      token: :bang,
      operator: "!",
      right: right
    }

    process_precedence(precedence, rest, errors, left)
  end

  defp parse_expression(precedence, [{:minus, "-"} | rest], errors, left) do
    {right, rest, errors} = parse_expression(@prefix, rest, errors, left)

    left = %Ast.PrefixExpression{
      token: :minus,
      operator: "-",
      right: right
    }

    process_precedence(precedence, rest, errors, left)
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
