defmodule BevagerScraper.Utils do
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

  def to_key_value(key, value) when is_nil(value) do
    "#{key}=NULL"
  end

  def to_key_value(key, value) when is_bitstring(value) do
    value = String.replace(value, "\"", "\\\"")
    "#{key}=\"#{value}\""
  end

  def to_key_value(key, value) when is_number(value) or is_boolean(value) do
    "#{key}=#{value}"
  end


  def to_key_value(key, value) do
    "#{key}=\"#{value}\""
  end


  def to_value(value) when is_nil(value) do
    "NULL"
  end

  def to_value(value) when is_bitstring(value) do
    value = String.replace(value, "\"", "\\\"")
    "\"#{value}\""
  end

  def to_value(value) when is_number(value) or is_boolean(value) do
    "#{value}"
  end


  def to_value(value) do
    "\"#{value}\""
  end

  def to_upsert(rum) do
    # until I move to ecto...
    iov = ["INSERT INTO rums.basic_rums (name, raw_name, request_status, notes, country, requested_at, rating, size, price, is_new, is_available, is_immortal) VALUES ("]
    values = for key <- [:name, :raw_name, :request_status, :notes, :country, :requested_at, :rating, :size, :price, :is_new, :is_available, :is_immortal] do
      {:ok, value} = Map.fetch(rum, key)
      to_value(value)
    end

    iov = iov ++ [Enum.join(values, ", ")] ++ [")\n"]
    iov = iov ++ ["ON DUPLICATE KEY UPDATE\n"]
    updates = for key <- [:request_status, :notes, :requested_at, :is_available, :is_immortal, :is_new, :rating, :size, :price] do
      {:ok, value} = Map.fetch(rum, key)
      to_key_value(key, value)
    end

    iov = iov ++ [Enum.join(updates, ", ")] ++ [";\n"]
    iov
  end
end
