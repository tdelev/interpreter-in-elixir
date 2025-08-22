defmodule Lexer do
  defguardp is_letter(c) when c in ?a..?z or ?A..?Z or c == ?_
  defguardp is_digit(c) when c in ?0..?9
  defguardp is_whitespace(c) when c in ~c[ \n\t]

  def init(input) when is_binary(input) do
    lex(input, [])
  end

  defp lex(<<>>, tokens) do
    [{:eof, ""} | tokens] |> Enum.reverse()
  end

  defp lex(<<c::8, rest::binary>>, tokens) when is_whitespace(c) do
    lex(rest, tokens)
  end

  defp lex(input, tokens) do
    {token, rest} = tokenize(input)
    lex(rest, [token | tokens])
  end

  defp tokenize(<<"+", rest::binary>>), do: {{:plus, "+"}, rest}

  defp tokenize(<<"=", rest::binary>>) do
    case rest do
      <<"=", rest::binary>> -> {{:eq, "=="}, rest}
      _ -> {{:assign, "="}, rest}
    end
  end

  defp tokenize(<<"(", rest::binary>>), do: {{:lparen, "("}, rest}
  defp tokenize(<<")", rest::binary>>), do: {{:rparen, ")"}, rest}
  defp tokenize(<<"{", rest::binary>>), do: {{:lbrace, "{"}, rest}
  defp tokenize(<<"}", rest::binary>>), do: {{:rbrace, "}"}, rest}
  defp tokenize(<<",", rest::binary>>), do: {{:comma, ","}, rest}
  defp tokenize(<<";", rest::binary>>), do: {{:semicolon, ";"}, rest}

  defp tokenize(<<"!", rest::binary>>) do
    case rest do
      <<"=", rest::binary>> ->
        {{:not_eq, "!="}, rest}

      _ ->
        {{:bang, "!"}, rest}
    end
  end

  defp tokenize(<<"<", rest::binary>>), do: {{:lt, "<"}, rest}
  defp tokenize(<<">", rest::binary>>), do: {{:gt, ">"}, rest}
  defp tokenize(<<"-", rest::binary>>), do: {{:minus, "-"}, rest}
  defp tokenize(<<"/", rest::binary>>), do: {{:slash, "/"}, rest}
  defp tokenize(<<"*", rest::binary>>), do: {{:asterisk, "*"}, rest}
  defp tokenize(<<"[", rest::binary>>), do: {{:lbracket, "["}, rest}
  defp tokenize(<<"]", rest::binary>>), do: {{:rbracket, "]"}, rest}
  defp tokenize(<<"\"", rest::binary>>), do: read_string(rest, [])
  defp tokenize(<<c::8, rest::binary>>) when is_letter(c), do: read_identifier(rest, <<c>>)
  defp tokenize(<<c::8, rest::binary>>) when is_digit(c), do: read_number(rest, <<c>>)
  defp tokenize(<<c::8, rest::binary>>), do: {{:ilegal, <<c>>}, rest}

  defp read_identifier(<<c::8, rest::binary>>, acc) when is_letter(c),
    do: read_identifier(rest, [acc | <<c>>])

  defp read_identifier(rest, acc), do: {IO.iodata_to_binary(acc) |> tokenize_word(), rest}

  defp read_string(<<"\"", rest::binary>>, acc), do: {{:string, IO.iodata_to_binary(acc)}, rest}
  defp read_string(<<c::8, rest::binary>>, acc), do: read_string(rest, [acc | <<c>>])

  defp read_number(<<c::8, rest::binary>>, acc) when is_digit(c),
    do: read_number(rest, [acc | <<c>>])

  defp read_number(rest, acc), do: {{:int, IO.iodata_to_binary(acc)}, rest}

  defp tokenize_word("let"), do: {:let, "let"}
  defp tokenize_word("fn"), do: {:function, "fn"}
  defp tokenize_word("if"), do: {:if, "if"}
  defp tokenize_word("else"), do: {:else, "else"}
  defp tokenize_word("return"), do: {:return, "return"}
  defp tokenize_word("true"), do: {:t, "true"}
  defp tokenize_word("false"), do: {:f, "false"}
  defp tokenize_word(ident), do: {:identifier, ident}
end
