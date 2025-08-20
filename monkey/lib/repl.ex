defmodule Repl do

  def start() do
    input = IO.gets(">> ") |> String.trim()

    if input != "\\q" do
      tokens = Lexer.init(input)
      Enum.each(tokens, fn token -> IO.puts(inspect(token)) end)
      start()
    else
      IO.puts("Goodbye!")
    end
  end
end

