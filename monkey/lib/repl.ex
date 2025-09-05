defmodule Repl do
  def start() do
    input = IO.gets(">> ") |> String.trim()

    if input != "\\q" do
      tokens = Lexer.init(input)
      {program, errors} = Parser.parse(tokens)

      if length(errors) > 0 do
        Enum.each(errors, fn error -> IO.puts(inspect(error)) end)
      else
        # IO.puts(inspect(program))
        # IO.puts(to_string(program))
        result = Eval.eval(program)
        IO.puts(result)
      end

      start()
    else
      IO.puts("Goodbye!")
    end
  end
end
