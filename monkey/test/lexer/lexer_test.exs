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
        {:less, "<"},
        {:int, "10"},
        {:greater, ">"},
        {:int, "5"},
        {:semicolon, ";"},
        {:eof, ""}
      ]

      assert Lexer.init(input) == expected
    end
  end
end
