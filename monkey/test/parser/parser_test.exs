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

      assert length(errors) == 0

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
        let 838383"
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

      assert length(errors) == 0

      assert program == %Ast.Program{
               statements: [
                 %Ast.ReturnStatment{
                   token: :return,
                   value: nil
                 },
                 %Ast.ReturnStatment{
                   token: :return,
                   value: nil
                 },
                 %Ast.ReturnStatment{
                   token: :return,
                   value: nil
                 }
               ]
             }
    end
  end
end
