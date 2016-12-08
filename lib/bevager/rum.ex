defmodule Bevager.Rum do
  defstruct name: nil, price: nil, is_new: nil, is_historic: nil,
  requested_at: nil, request_status: nil, notes: nil, country: nil, rating: nil

  defp parse_requested([""]) do
    nil
  end

  defp parse_requested([s]) do
    case Timex.parse(s, "%a, %b %e at %I:%M %p", :strftime) do
      # Interesting enough, bevager doesn't store or send down the year.
      {:ok, dt} ->
        case dt.year do
          0 ->
            # TODO: if month > current month, use current year -1
            {:ok, dt2} = NaiveDateTime.new(2016, dt.month, dt.day, dt.hour, dt.minute, 0)
            dt2
          _ -> dt
        end
      {:error, _} ->
        {:ok, dt} = Timex.parse(s, "%m/%e/%y", :strftime)
        dt
    end
  end

  defp parse_historic([class]) do
    "historic-item" in String.split(class)
  end

  defp parse_price(s) do
    m = Regex.named_captures(~r/\$(?<price>[0-9]+).*/, s)
    {price, _} = Integer.parse(m["price"])
    price
  end

  defp parse_notes([{_, _, [notes]}]) do
    m = Regex.named_captures(~r/(?<notes>.*)(?<rating>[0-9].?[0-9]?)\*/U, notes)
    notes = case m["notes"] do
              nil -> ""
              _ -> String.trim(m["notes"])
            end
    {rating, _} = case m["rating"] do
                    nil -> {nil, nil}
                    _ -> Float.parse(m["rating"])
                  end
    {notes, rating}
  end

  defp parse_notes(_) do
    {nil, nil}
  end

  def new_from_floki(html) do
    #IO.inspect html
    children = Floki.find(html, "td")
    {:ok, {"td", _, [p]}} = Enum.fetch(children, 2)
    price = parse_price(p)

    {:ok, {"td", _, [{_, _, [country]}]}} = Enum.fetch(children, 0)
    {:ok, {"td", _, stuff}} = Enum.fetch(children, 3)
    request_status = case Enum.fetch(stuff, 1) do
                       {:ok, status} -> String.trim(status)
                       :error -> nil
                     end



    class = Floki.attribute(html, "class")
    is_historic = parse_historic(class)
    requested_at = parse_requested(Floki.attribute(html, "data-requested"))

    [{_, _, [name]}] = Floki.find(html, "a.item-name")
    name = String.trim(name)
    is_new = String.starts_with?(name, "*")
    name = case is_new do
             true -> String.trim_leading(name, "*")
             _ -> name
           end

    {notes, rating} = parse_notes(Floki.find(html, "div.notes"))

    %Bevager.Rum{
      name: name,
      price: price,
      is_new: is_new,
      is_historic: is_historic,
      requested_at: requested_at,
      request_status: request_status,
      notes: notes,
      country: country,
      rating: rating
    }
  end
end
