defmodule Eval do
  def eval(%Ast.Program{statements: statements}) do
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

  defp eval_expression(%Ast.PrefixExpression{token: _token, operator: operator, right: right}) do
    case operator do
      "-" ->
        %Object.Integer{value: right_value, type: _type} = eval_expression(right)
        %Object.Integer{value: -right_value, type: :int}

      "!" ->
        %Object.Boolean{value: right_value, type: _type} = eval_expression(right)
        %Object.Boolean{value: !right_value, type: :boolean}
    end
  end

  defp eval_expression(%Ast.Boolean{token: _token, value: value}) do
    if value do
      Object.Boolean.t()
    else
      Object.Boolean.f()
    end
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
