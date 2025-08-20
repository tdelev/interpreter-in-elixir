defmodule AstTest do
  use ExUnit.Case
  doctest Ast

  describe "test AST" do
    test "should generate program string" do
      input = %Ast.Program{
        statements: [
          %Ast.LetStatement{
            token: :let,
            name: %Ast.Identifier{
              token: :identifier,
              value: "myVar"
            },
            value: %Ast.Identifier{
              token: :identifier,
              value: "anotherVar"
            }
          }
        ]
      }

      assert "#{input}" == "let myVar = anotherVar;"
    end
  end
end
