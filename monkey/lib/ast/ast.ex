defmodule Ast do
end

defmodule Ast.Program do
  defstruct [:statements]
end

defimpl String.Chars, for: Ast.Program do
  def to_string(p) do
    Enum.join(p.statements)
  end
end

defmodule Ast.LetStatement do
  defstruct [:token, :name, :value]
end

defimpl String.Chars, for: Ast.LetStatement do
  def to_string(let) do
    "#{let.token} #{let.name} = #{let.value};"
  end
end

defmodule Ast.Identifier do
  defstruct [:token, :value]
end

defimpl String.Chars, for: Ast.Identifier do
  def to_string(x) do
    x.value
  end
end

defmodule Ast.ReturnStatement do
  defstruct [:token, :value]
end

defimpl String.Chars, for: Ast.ReturnStatement do
  def to_string(x) do
    "#{x.token} #{x.value};"
  end
end

defmodule Ast.ExpressionStatement do
  defstruct [:token, :expression]
end

defimpl String.Chars, for: Ast.ExpressionStatement do
  def to_string(x) do
    "#{x.expression}"
  end
end

defmodule Ast.IntegerLiteral do
  defstruct [:token, :value]
end

defimpl String.Chars, for: Ast.IntegerLiteral do
  def to_string(x) do
    "#{x.value}"
  end
end

defmodule Ast.PrefixExpression do
  defstruct [:token, :operator, :right]
end

defimpl String.Chars, for: Ast.PrefixExpression do
  def to_string(x) do
    "(#{x.operator}#{x.right})"
  end
end

defmodule Ast.InfixExpression do
  defstruct [:token, :left, :operator, :right]
end

defimpl String.Chars, for: Ast.InfixExpression do
  def to_string(x) do
    "(#{x.left} #{x.operator} #{x.right})"
  end
end

defmodule Ast.Boolean do
  defstruct [:token, :value]
end

defimpl String.Chars, for: Ast.Boolean do
  def to_string(x) do
    "#{x.value}"
  end
end

defmodule Ast.IfExpression do
  defstruct [:token, :condition, :if_true, :if_false]
end

defimpl String.Chars, for: Ast.IfExpression do
  def to_string(x) do
    if_false =
      if x.if_false != nil do
        "else #{x.if_false}"
      else
        ""
      end

    "if#{x.condition} #{x.if_true}#{if_false}"
  end
end

defmodule Ast.BlockStatement do
  defstruct [:token, :statements]
end

defimpl String.Chars, for: Ast.BlockStatement do
  def to_string(x) do
    Enum.join(x.statements)
  end
end

defmodule Ast.FunctionLiteral do
  defstruct [:token, :parameters, :body]
end

defimpl String.Chars, for: Ast.FunctionLiteral do
  def to_string(x) do
    params = Enum.join(x.parameters, ", ")
    "fn (#{params}) #{x.body}"
  end
end

defmodule Ast.CallExpression do
  defstruct [:token, :function, :arguments]
end

defimpl String.Chars, for: Ast.CallExpression do
  def to_string(x) do
    params = Enum.join(x.arguments, ", ")
    "#{x.function} (#{params})"
  end
end
