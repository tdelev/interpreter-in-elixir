defmodule Parser do
  alias Ast.Program

  @precedence %{
    :eq => 0,
    :not_eq => 1
  }
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
    {e, rest, errors} = parse_expression_statement(tokens, errors)

    program = %{program | statements: program.statements ++ [e]}
    parse_program(rest, program, errors)
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

  defp parse_let_statement([{:assign, "="} | rest], let, errors) do
    # errors = check_error(rest, :assign, errors)
    parse_let_statement(rest, let, errors)
  end

  defp parse_let_statement([{:semicolon, ";"} | rest], let, errors) do
    {let, rest, errors}
  end

  defp parse_let_statement([_exprssion | rest], let, errors) do
    parse_let_statement(rest, let, errors)
  end

  defp parse_let_statement([], let, errors) do
    {let, [], errors}
  end

  defp parse_return_statement([{:semicolon, ";"} | rest], return, errors) do
    {return, rest, errors}
  end

  defp parse_return_statement([_expression | rest], return, errors) do
    parse_return_statement(rest, return, errors)
  end

  defp parse_expression_statement(tokens, errors) do
    {expression, rest, errors} = parse_expression(tokens, errors)

    {%Ast.ExpressionStatement{
       token: expression.token,
       expression: expression
     }, rest, errors}
  end

  defp parse_expression([{:semicolon, ";"} | rest], errors, left) do
    {left, rest, errors}
  end

  defp parse_expression([{:eof, ""}], errors, left) do
    {left, [{:eof, ""}], errors}
  end

  defp parse_expression([], errors, left) do
    {left, [], errors}
  end

  defp parse_expression([{:identifier, x} | rest], errors) do
    {errors, rest} = check_error(rest, {:semicolon, ";"}, errors)

    {%Ast.Identifier{token: :identifier, value: x}, rest, errors}
  end

  defp parse_expression([{:int, x} | rest], errors) do
    # {errors, rest} = check_error(rest, {:semicolon, ";"}, errors)

    left = %Ast.IntegerLiteral{
      token: :int,
      value: String.to_integer(x)
    }

    parse_expression(rest, errors, left)
  end

  defp parse_expression([{:bang, "!"} | rest], errors) do
    {right, rest, errors} = parse_expression(rest, errors)

    left = %Ast.PrefixExpression{
      token: :bang,
      operator: "!",
      right: right
    }

    parse_expression(rest, errors, left)
  end

  defp parse_expression([{:minus, "-"} | rest], errors) do
    {right, rest, errors} = parse_expression(rest, errors)

    left = %Ast.PrefixExpression{
      token: :minus,
      operator: "-",
      right: right
    }

    parse_expression(rest, errors, left)
  end

  # defp parse_expression(tokens, errors) do
  #   [first | rest] = tokens
  #
  #   {%Ast.PrefixExpression{
  #      token: :minus,
  #      operator: "-",
  #      right: right
  #    }, rest, errors}
  # end
end
