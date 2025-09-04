defmodule EvalTest do
  use ExUnit.Case
  doctest Eval

  defp run(input) do
    tokens = Lexer.init(input)
    {program, _errors} = Parser.parse(tokens)
    hd(Eval.eval(program))
  end

  describe "test Eval.eval/1" do
    test "should eval integer literal" do
      input = "10"
      result = run(input)

      assert result == %Object.Integer{value: 10, type: :int}
    end

    test "should eval math expression" do
      input = "10 * 15"
      result = run(input)

      assert result == %Object.Integer{value: 150, type: :int}
    end
  end
end
