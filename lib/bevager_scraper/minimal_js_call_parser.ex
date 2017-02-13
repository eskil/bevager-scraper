defmodule MinimalJsCallParser do
  defp post_process([], acc) do
    acc
  end

  defp post_process([{:string, val} | tail], acc) do
    # We convert charlists to strings.
    [{:string, to_string(val)}] ++ post_process(tail, acc)
  end

  defp post_process([{:call, obj, func, args} | tail], acc) do
    stringed_args = post_process(args, [])
    post_process(tail, [{:call, obj, func, stringed_args}] ++ acc)
  end

  defp post_process([head | tail], acc) do
    [head] ++ post_process(tail, acc)
  end

  def parse(string) do
    {:ok, tokens, _} = :min_js_calls_lexer.string(String.to_char_list(string))
    {:ok, tree} = :min_js_calls.parse(tokens)
    {:ok, post_process(tree, [])}
  end
end
