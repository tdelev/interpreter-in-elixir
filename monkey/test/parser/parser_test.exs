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
                   token: {:let, "let"},
                   name: %Ast.Identifier{
                     token: {:identifier, "x"},
                     value: "x"
                   },
                   value: nil
                 },
                 %Ast.LetStatement{
                   token: {:let, "let"},
                   name: %Ast.Identifier{
                     token: {:identifier, "y"},
                     value: "y"
                   },
                   value: nil
                 },
                 %Ast.LetStatement{
                   token: {:let, "let"},
                   name: %Ast.Identifier{
                     token: {:identifier, "foobar"},
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
                   token: {:return, "return"},
                   value: nil
                 },
                 %Ast.ReturnStatement{
                   token: {:return, "return"},
                   value: nil
                 },
                 %Ast.ReturnStatement{
                   token: {:return, "return"},
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
                   token: {:identifier, "foobar"},
                   expression: %Ast.Identifier{
                     token: {:identifier, "foobar"},
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
                   token: {:int, "5"},
                   expression: %Ast.IntegerLiteral{
                     token: {:int, "5"},
                     value: 5
                   }
                 }
               ]
             }
    end

    test "should parse boolean literal expression" do
      inputs = [{"true;", true, :t}, {"false;", false, :f}]

      for test <- inputs do
        {input, value, token} = test
        tokens = Lexer.init(input)
        {program, errors} = Parser.parse(tokens)

        assert_no_errors(errors)

        assert program == %Ast.Program{
                 statements: [
                   %Ast.ExpressionStatement{
                     token: {token, to_string(value)},
                     expression: %Ast.Boolean{
                       token: {token, to_string(value)},
                       value: value
                     }
                   }
                 ]
               }
      end
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
                     token: {token, operator},
                     expression: %Ast.PrefixExpression{
                       token: {token, operator},
                       operator: operator,
                       right: %Ast.IntegerLiteral{
                         token: {:int, to_string(value)},
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
                     token: {token, operator},
                     expression: %Ast.InfixExpression{
                       token: {token, operator},
                       left: %Ast.IntegerLiteral{
                         token: {:int, to_string(left)},
                         value: left
                       },
                       operator: operator,
                       right: %Ast.IntegerLiteral{
                         token: {:int, to_string(right)},
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
        {"a * b / c", "((a * b) / c)"},
        {"1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"},
        {"(5 + 5) * 2", "((5 + 5) * 2)"},
        {"2 / (5 + 5)", "(2 / (5 + 5))"},
        {"-(5 + 5)", "(-(5 + 5))"},
        {"!(true == true)", "(!(true == true))"}
      ]

      for test <- inputs do
        {input, expected} = test
        tokens = Lexer.init(input)
        {program, errors} = Parser.parse(tokens)

        assert_no_errors(errors)

        assert to_string(program) == expected
      end
    end

    test "should parse if expression" do
      input = "if (x < y) { x }"
      tokens = Lexer.init(input)
      {program, errors} = Parser.parse(tokens)

      assert_no_errors(errors)

      assert program == %Ast.Program{
               statements: [
                 %Ast.ExpressionStatement{
                   expression: %Ast.IfExpression{
                     condition: %Ast.InfixExpression{
                       left: %Ast.Identifier{token: {:identifier, "x"}, value: "x"},
                       operator: "<",
                       right: %Ast.Identifier{token: {:identifier, "y"}, value: "y"},
                       token: {:lt, "<"}
                     },
                     if_false: nil,
                     if_true: %Ast.BlockStatement{
                       token: {:lbrace, "{"},
                       statements: [
                         %Ast.ExpressionStatement{
                           token: {:identifier, "x"},
                           expression: %Ast.Identifier{token: {:identifier, "x"}, value: "x"}
                         }
                       ]
                     },
                     token: {:if, "if"}
                   },
                   token: {:if, "if"}
                 }
               ]
             }
    end
  end

  defp assert_no_errors(errors), do: assert(length(errors) == 0)
end
