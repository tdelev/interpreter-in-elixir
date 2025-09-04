defmodule Eval do
  def eval(%Ast.Program{statements: statements}) do
    IO.puts("program: #{inspect(statements)}")
    eval_statements(statements, [])
  end

  defp eval_statements([], result), do: result

  defp eval_statements([stmt | rest], result) do
    res = eval_statement(stmt)
    eval_statements(rest, result ++ [res])
  end

  defp eval_statement(%Ast.ExpressionStatement{token: _token, expression: expression}) do
    eval_expression(expression)
  end

  defp eval_expression(%Ast.IntegerLiteral{token: _token, value: value}) do
    %Object.Integer{value: value, type: :int}
  end

  defp eval_expression(%Ast.InfixExpression{
         token: _token,
         left: left,
         operator: operator,
         right: right
       }) do
    %Object.Integer{value: left_value, type: _type} = eval_expression(left)
    %Object.Integer{value: right_value, type: _type} = eval_expression(right)

    result =
      case operator do
        "+" -> left_value + right_value
        "-" -> left_value - right_value
        "*" -> left_value * right_value
        "/" -> left_value / right_value
      end

    %Object.Integer{value: result, type: :int}
  end
end
