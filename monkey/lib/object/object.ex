defmodule Object do
end

defmodule Object.Integer do
  defstruct [:value, :type]
end

defimpl String.Chars, for: Object.Integer do
  def to_string(i) do
    "#{i.value}"
  end
end

defmodule Object.Boolean do
  defstruct [:value, :type]

  def t, do: %Object.Boolean{value: true, type: :boolean}
  def f, do: %Object.Boolean{value: false, type: :boolean}
end

defimpl String.Chars, for: Object.Boolean do
  def to_string(i) do
    "#{i.value}"
  end
end

defmodule Object.Null do
end

defimpl String.Chars, for: Object.Null do
  def to_string(n) do
    "null"
  end
end
