defmodule EvalTest do
  use ExUnit.Case
  doctest Eval

  defp run(input) do
    tokens = Lexer.init(input)
    {program, _errors} = Parser.parse(tokens)
    Eval.eval(program)
  end

  describe "test Eval.eval/1" do
    test "should eval integer literal" do
      input = "10"
      result = run(input)

      assert result == %Object.Integer{value: 10, type: :int}
    end

    test "should eval prefix expressions" do
      inputs =
        [
          {"-10", %Object.Integer{value: -10, type: :int}},
          {"!true", Object.Boolean.f()},
          {"!false", Object.Boolean.t()},
          {"!!false", Object.Boolean.f()},
          {"!!true", Object.Boolean.t()},
          {"!5", Object.Boolean.f()}
        ]

      for input <- inputs do
        {input, expected} = input
        result = run(input)
        assert result == expected
      end
    end

    test "should eval math expressions" do
      inputs = [
        {"10 * 15", 150},
        {"(1 + 2) * 3", 9},
        {"(10 - 5) * 2", 10}
      ]

      for input <- inputs do
        {input, expected} = input
        result = run(input)
        assert result == %Object.Integer{value: expected, type: :int}
      end
    end

    test "should eval compare expressions" do
      inputs = [
        {"10 < 15", true},
        {"10 > 15", false},
        {"10 == 15", false},
        {"10 != 15", true},
        {"5 == 5", true},
        {"5 != 5", false}
      ]

      for input <- inputs do
        {input, expected} = input
        result = run(input)
        assert result == %Object.Boolean{value: expected, type: :boolean}
      end
    end

    test "should eval if/else expressions" do
      inputs = [
        {"if (true) { 10 } else { 20 }", 10},
        {"if (false) { 10 } else { 20 }", 20},
        {"if (10 > 5) { 10 } else { 20 }", 10},
        {"if (10 < 5) { 10 } else { 20 }", 20}
      ]

      for input <- inputs do
        {input, expected} = input
        result = run(input)
        assert result == %Object.Integer{value: expected, type: :int}
      end
    end

    test "should eval return statements" do
      inputs = [
        {"return 10;", 10},
        {"return 10; 9;", 10},
        {"9; return 10; 9;", 10},
        {"9; return 2 * 5; 9;", 10}
      ]

      for input <- inputs do
        {input, expected} = input
        result = run(input)
        assert result == %Object.Integer{value: expected, type: :int}
      end
    end
  end
end
