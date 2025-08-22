defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  describe "test Lex.init/1" do
    test "should tokenize simple string" do
      input = "+=(){},;"

      expected = [
        {:plus, "+"},
        {:assign, "="},
        {:lparen, "("},
        {:rparen, ")"},
        {:lbrace, "{"},
        {:rbrace, "}"},
        {:comma, ","},
        {:semicolon, ";"},
        {:eof, ""}
      ]

      assert Lexer.init(input) == expected
    end

    test "should tokenize full program" do
      input = "
      let five = 5;
      let ten = 10;
      let add = fn(x, y) {
      x + y;
      };
      let result = add(five, ten);
      !-/*5;
      5 < 10 > 5;

      if (5 < 10) {
        return true;
      } else {
        return false;
      }

      10 == 10;
      10 != 9;
      \"foobar\"
      \"foo bar\"
      [1, 2];
      "

      expected = [
        {:let, "let"},
        {:identifier, "five"},
        {:assign, "="},
        {:int, "5"},
        {:semicolon, ";"},
        {:let, "let"},
        {:identifier, "ten"},
        {:assign, "="},
        {:int, "10"},
        {:semicolon, ";"},
        {:let, "let"},
        {:identifier, "add"},
        {:assign, "="},
        {:function, "fn"},
        {:lparen, "("},
        {:identifier, "x"},
        {:comma, ","},
        {:identifier, "y"},
        {:rparen, ")"},
        {:lbrace, "{"},
        {:identifier, "x"},
        {:plus, "+"},
        {:identifier, "y"},
        {:semicolon, ";"},
        {:rbrace, "}"},
        {:semicolon, ";"},
        {:let, "let"},
        {:identifier, "result"},
        {:assign, "="},
        {:identifier, "add"},
        {:lparen, "("},
        {:identifier, "five"},
        {:comma, ","},
        {:identifier, "ten"},
        {:rparen, ")"},
        {:semicolon, ";"},
        {:bang, "!"},
        {:minus, "-"},
        {:slash, "/"},
        {:asterisk, "*"},
        {:int, "5"},
        {:semicolon, ";"},
        {:int, "5"},
        {:lt, "<"},
        {:int, "10"},
        {:gt, ">"},
        {:int, "5"},
        {:semicolon, ";"},
        {:if, "if"},
        {:lparen, "("},
        {:int, "5"},
        {:lt, "<"},
        {:int, "10"},
        {:rparen, ")"},
        {:lbrace, "{"},
        {:return, "return"},
        {:t, "true"},
        {:semicolon, ";"},
        {:rbrace, "}"},
        {:else, "else"},
        {:lbrace, "{"},
        {:return, "return"},
        {:f, "false"},
        {:semicolon, ";"},
        {:rbrace, "}"},
        {:int, "10"},
        {:eq, "=="},
        {:int, "10"},
        {:semicolon, ";"},
        {:int, "10"},
        {:not_eq, "!="},
        {:int, "9"},
        {:semicolon, ";"},
        {:string, "foobar"},
        {:string, "foo bar"},
        {:lbracket, "["},
        {:int, "1"},
        {:comma, ","},
        {:int, "2"},
        {:rbracket, "]"},
        {:semicolon, ";"},
        {:eof, ""}
      ]

      assert Lexer.init(input) == expected
    end
  end
end
