defmodule Bevager.Utils do
  def trim_trailing_acc([head|tail], chars) do
    case head in chars do
      true -> trim_trailing_acc(tail, chars)
      _ -> [head|tail]
    end
  end

  def trim_trailing_acc([], _) do
    []
  end

  def trim_trailing(str, chars) do
    Enum.join(
      Enum.reverse(
	      trim_trailing_acc(
	        Enum.reverse(
	          String.graphemes(str)
	        ),
	        String.graphemes(chars)
	      )
      )
    )
  end
end
