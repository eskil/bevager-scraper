defmodule BevagerScraper.Rum do
  defstruct name: nil,
    raw_name: nil,
    price: nil,
    is_new: nil,
    is_historic: nil,
    is_immortal: nil,
    requested_at: nil,
    request_status: nil,
    notes: nil,
    country: nil,
    state: nil,
    rating: nil,
    size: nil

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

  defp parse_is_immortal(name) do
    is_immortal = String.contains?(name, "Immortal")
    name = case is_immortal do
             true ->
               name |> String.replace("Immortal", "")
                    |> BevagerScraper.Utils.trim_trailing(" -?")
                    |> String.trim
             _ -> name
           end
    {is_immortal, name}
  end

  defp parse_is_new(name) do
    is_new = String.starts_with?(name, "*")
    name = case is_new do
             true -> String.trim_leading(name, "*")
             _ -> name
           end
    {is_new, name}
  end

  defp parse_size(name) do
    size = case Regex.match?(~r/1\s?oz/, name) do
             true -> 1
             _ -> 2
           end
    name = case size == 1 do
             true ->
               name |> String.trim_trailing("1 oz")
                    |> String.trim_trailing("1 oz.")
                    |> String.trim_trailing("1oz")
                    |> String.trim_trailing("1oz.")
                    |> BevagerScraper.Utils.trim_trailing(" -?")
             _ -> name
           end
    {size, name}
  end

  defp parse_state(country, name) when country in ["United States"] do
    case Regex.named_captures(~r/(?<name>.*) \((?<state>.*)\)/U, name) do
      nil ->
        {nil, name}
      match ->
        {match["state"], match["name"]}
    end
  end

  defp parse_state(_country, name) do
    {nil, name}
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

    # TODO: make a parse_new that returns new and name.
    [{_, _, [raw_name]}] = Floki.find(html, "a.item-name")
    raw_name = String.trim(raw_name)
    name = String.replace(raw_name, "  ", " ", global: true)
    {state, name} = parse_state(country, name)
    {is_new, name} = parse_is_new(name)
    {is_immortal, name} = parse_is_immortal(name)
    {size, name} = parse_size(name)
    {notes, rating} = parse_notes(Floki.find(html, "div.notes"))

    %BevagerScraper.Rum{
      name: name,
      raw_name: raw_name,
      price: price,
      is_new: is_new,
      is_historic: is_historic,
      is_immortal: is_immortal,
      requested_at: requested_at,
      request_status: request_status,
      notes: notes,
      country: country,
      state: state,
      rating: rating,
      size: size
    }
  end
end
