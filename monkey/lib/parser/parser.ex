defmodule Parser do
  alias Ast.Program

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
    errors = check_error(rest, {:identifier, "IDENT"}, errors)
    {let, rest, errors} = parse_let_statement(rest, %Ast.LetStatement{token: :let}, errors)
    program = %{program | statements: program.statements ++ [let]}
    parse_program(rest, program, errors)
  end

  defp parse_program([{:return, "return"} | rest], program, errors) do
    {let, rest, errors} =
      parse_return_statement(rest, %Ast.ReturnStatment{token: :return}, errors)

    program = %{program | statements: program.statements ++ [let]}
    parse_program(rest, program, errors)
  end

  # defp parse_program(tokens, program), do: parse_expression_statement(tokens, program)

  # defp parse_expression_statement(tokens, prorgram) do
  # end

  defp check_error(tokens, {expected, literal}, errors) do
    [{next_token, _} | _] = tokens

    if next_token != expected do
      errors ++ ["expected next token to be #{literal}, got #{next_token} instead"]
    else
      errors
    end
  end

  defp parse_let_statement([{:identifier, x} | rest], let, errors) do
    identifier = %Ast.Identifier{token: :identifier, value: x}
    errors = check_error(rest, {:assign, "="}, errors)
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
end
