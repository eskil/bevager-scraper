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

  def to_key_val(key, value) when is_nil(value) do
    "#{key}=NULL"
  end

  def to_key_val(key, value) when is_bitstring(value) do
    value = String.replace(value, "\"", "\\\"")
    "#{key}=\"#{value}\""
  end


  def to_upsert(rum) do
    # until I move to ecto...
    iov = ["INSERT INTO rums.basic_rums (name, raw_name, request_status, notes, country, requested_at, rating, size, price, is_new, is_historic, is_immortal) VALUES ("]
    values = []

    # Strings
    values = values ++ for key <- [:name, :raw_name, :request_status, :notes, :country] do
      {:ok, value} = Map.fetch(rum, key)
      case value == nil do
        true -> "NULL"
        _ ->
          value = String.replace(value, "\"", "\\\"")
          "#{key}=\"#{value}\""
      end
    end

    # Dates
    values = values ++ for key <- [:requested_at] do
      {:ok, value} = Map.fetch(rum, key)
      case value == nil do
        true -> "NULL"
        _ ->
          "#{key}=\"#{value}\""
      end
    end

    # Numbers
    values = values ++ for key <- [:rating, :size, :price] do
      {:ok, value} = Map.fetch(rum, key)
      case value == nil do
        true -> "NULL"
        _ -> "#{value}"
      end
    end

    # Bools
    values = values ++ for key <- [:is_new, :is_historic, :is_immortal] do
      {:ok, value} = Map.fetch(rum, key)
      case value do
        true -> "true"
        _ -> "false"
      end
    end

    iov = iov ++ [Enum.join(values, ", ")] ++ [")\n"]
    iov = iov ++ ["ON DUPLICATE KEY UPDATE\n"]
    updates = []

    # Strings
    updates = updates ++ for key <- [:request_status, :notes] do
      {:ok, value} = Map.fetch(rum, key)
      case value == nil do
        true -> "#{key}=NULL"
        _ ->
          value = String.replace(value, "\"", "\\\"")
          "#{key}=\"#{value}\""
      end
    end

    # Dates
    updates = updates ++ for key <- [:requested_at] do
      {:ok, value} = Map.fetch(rum, key)
      case value == nil do
        true -> "#{key}=NULL"
        _ ->
          "#{key}=\"#{value}\""
      end
    end

    # Bools
    updates = updates ++ for key <- [:is_historic, :is_immortal, :is_new] do
      {:ok, value} = Map.fetch(rum, key)
      case value do
        true -> "#{key}=true"
        _ -> "#{key}=false"
      end
    end

    # Numbers
    updates = updates ++ for key <- [:rating, :size, :price] do
      {:ok, value} = Map.fetch(rum, key)
      case value == nil do
        true -> "#{key}=NULL"
        _ -> "#{key}=#{value}"
      end
    end

    iov = iov ++ [Enum.join(updates, ", ")] ++ [";\n"]
    iov
  end
end
