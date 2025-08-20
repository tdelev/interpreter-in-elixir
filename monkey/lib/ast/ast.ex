defmodule Ast do
end

defmodule Ast.Program do
  defstruct [:statements]
end

defmodule Ast.LetStatement do
  defstruct [:token, :name, :value]
end

defmodule Ast.Identifier do
  defstruct [:token, :value]
end

defmodule Ast.ReturnStatment do
  defstruct [:token, :value]
end

# IO.puts(Ast.Program.)
