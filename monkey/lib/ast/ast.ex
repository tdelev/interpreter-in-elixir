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
    "#{x.operator}#{x.right}"
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

# IO.puts(Ast.Program.)
