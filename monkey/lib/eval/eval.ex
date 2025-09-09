defmodule Eval do
  def eval(%Ast.Program{statements: statements}) do
    hd(eval_statements(statements, []))
  end

  defp eval_statements([], result), do: result

  defp eval_statements([stmt | rest], result) do
    res = eval_statement(stmt)

    case res do
      %Object.ReturnValue{value: value} ->
        [value]

      _ ->
        eval_statements(rest, [res | result])
    end
  end

  defp eval_statement(%Ast.ExpressionStatement{token: _token, expression: expression}) do
    eval_expression(expression)
  end

  defp eval_statement(%Ast.ReturnStatement{token: _token, value: value}) do
    %Object.ReturnValue{value: eval_expression(value)}
  end

  defp eval_expression(%Ast.BlockStatement{token: _token, statements: statements}) do
    hd(eval_statements(statements, []))
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
        expression = eval_expression(right)

        case expression.type do
          :boolean ->
            %Object.Boolean{value: !expression.value, type: :boolean}

          _ ->
            Object.Boolean.f()
        end
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

    {result, type} =
      case operator do
        "+" -> {left_value + right_value, :int}
        "-" -> {left_value - right_value, :int}
        "*" -> {left_value * right_value, :int}
        "/" -> {left_value / right_value, :int}
        "<" -> {left_value < right_value, :boolean}
        "==" -> {left_value == right_value, :boolean}
        ">" -> {left_value > right_value, :boolean}
        "!=" -> {left_value != right_value, :boolean}
      end

    case type do
      :int -> %Object.Integer{value: result, type: :int}
      :boolean -> %Object.Boolean{value: result, type: :boolean}
    end
  end

  defp eval_expression(%Ast.IfExpression{
         token: _token,
         condition: condition,
         if_true: if_true,
         if_false: if_false
       }) do
    result = eval_expression(condition)

    if result.value do
      eval_expression(if_true)
    else
      eval_expression(if_false)
    end
  end
end
