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
