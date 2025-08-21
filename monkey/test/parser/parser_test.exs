defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  describe "test Parser.parse/1" do
    test "should parse let statements" do
      input = "
        let x = 5;
        let y = 10;
        let foobar = 123124;
      "
      tokens = Lexer.init(input)
      {program, errors} = Parser.parse(tokens)

      assert_no_errors(errors)

      assert program == %Ast.Program{
               statements: [
                 %Ast.LetStatement{
                   token: :let,
                   name: %Ast.Identifier{
                     token: :identifier,
                     value: "x"
                   },
                   value: nil
                 },
                 %Ast.LetStatement{
                   token: :let,
                   name: %Ast.Identifier{
                     token: :identifier,
                     value: "y"
                   },
                   value: nil
                 },
                 %Ast.LetStatement{
                   token: :let,
                   name: %Ast.Identifier{
                     token: :identifier,
                     value: "foobar"
                   },
                   value: nil
                 }
               ]
             }
    end

    test "should produce errors from parsing" do
      input = "let x 5;
        let = 10;
        let 838383;"
      tokens = Lexer.init(input)
      {_, errors} = Parser.parse(tokens)

      assert length(errors) == 3
      assert Enum.at(errors, 0) == "expected next token to be =, got int instead"
      assert Enum.at(errors, 1) == "expected next token to be IDENT, got assign instead"
      assert Enum.at(errors, 2) == "expected next token to be IDENT, got int instead"
    end

    test "should parse return statements" do
      input = "
        return 5;
        return 10;
        return add(15);
      "
      tokens = Lexer.init(input)
      {program, errors} = Parser.parse(tokens)

      assert_no_errors(errors)

      assert program == %Ast.Program{
               statements: [
                 %Ast.ReturnStatement{
                   token: :return,
                   value: nil
                 },
                 %Ast.ReturnStatement{
                   token: :return,
                   value: nil
                 },
                 %Ast.ReturnStatement{
                   token: :return,
                   value: nil
                 }
               ]
             }
    end

    test "should parse identifier expression" do
      input = "foobar;"
      tokens = Lexer.init(input)
      {program, errors} = Parser.parse(tokens)

      assert_no_errors(errors)

      assert program == %Ast.Program{
               statements: [
                 %Ast.ExpressionStatement{
                   token: :identifier,
                   expression: %Ast.Identifier{
                     token: :identifier,
                     value: "foobar"
                   }
                 }
               ]
             }
    end

    test "should parse integer literal expression" do
      input = "5;"
      tokens = Lexer.init(input)
      {program, errors} = Parser.parse(tokens)

      assert_no_errors(errors)

      assert program == %Ast.Program{
               statements: [
                 %Ast.ExpressionStatement{
                   token: :int,
                   expression: %Ast.IntegerLiteral{
                     token: :int,
                     value: 5
                   }
                 }
               ]
             }
    end

    test "should parse prefix expression" do
      inputs = [
        {"!5;", "!", 5, :bang},
        {"-15;", "-", 15, :minus}
      ]

      for test <- inputs do
        {input, operator, value, token} = test
        tokens = Lexer.init(input)
        {program, errors} = Parser.parse(tokens)

        assert_no_errors(errors)

        assert program == %Ast.Program{
                 statements: [
                   %Ast.ExpressionStatement{
                     token: token,
                     expression: %Ast.PrefixExpression{
                       token: token,
                       operator: operator,
                       right: %Ast.IntegerLiteral{
                         token: :int,
                         value: value
                       }
                     }
                   }
                 ]
               }
      end
    end

    test "should parse infix expressions" do
      inputs = [
        {"5 + 5;", 5, "+", 5, :plus},
        {"5 - 5;", 5, "-", 5, :minus},
        {"5 / 5;", 5, "/", 5, :slash},
        {"5 * 5;", 5, "*", 5, :asterisk},
        {"5 > 5;", 5, ">", 5, :gt},
        {"5 < 5;", 5, "<", 5, :lt},
        {"5 == 5;", 5, "==", 5, :eq},
        {"5 != 5;", 5, "!=", 5, :not_eq}
      ]

      for test <- inputs do
        {input, left, operator, right, token} = test
        tokens = Lexer.init(input)
        {program, errors} = Parser.parse(tokens)

        assert_no_errors(errors)

        assert program == %Ast.Program{
                 statements: [
                   %Ast.ExpressionStatement{
                     token: token,
                     expression: %Ast.InfixExpression{
                       token: token,
                       left: %Ast.IntegerLiteral{
                         token: :int,
                         value: left
                       },
                       operator: operator,
                       right: %Ast.IntegerLiteral{
                         token: :int,
                         value: right
                       }
                     }
                   }
                 ]
               }
      end
    end

    test "should test operator precedence" do
      inputs = [
        {"-a * b", "((-a) * b)"},
        {"!-a", "(!(-a))"},
        {"a + b + c", "((a + b) + c)"},
        {"a + b - c", "((a + b) - c)"},
        {"a * b * c", "((a * b) * c)"},
        {"a * b / c", "((a * b) / c)"},
        {"a + b / c", "(a + (b / c))"},
        {"a + b + c + d", "(((a + b) + c) + d)"},
        {"a + b * c + d", "((a + (b * c)) + d)"},
        {"a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"},
        {"a * b / c", "((a * b) / c)"}
      ]

      for test <- inputs do
        {input, expected} = test
        tokens = Lexer.init(input)
        {program, errors} = Parser.parse(tokens)

        assert_no_errors(errors)

        assert to_string(program) == expected
      end
    end
  end

  defp assert_no_errors(errors), do: assert(length(errors) == 0)
end
