defmodule BevagerScraper.Rum do
  defstruct remote_id: nil,
    name: nil,
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
    class = Floki.attribute(html, "class")
    is_historic = parse_historic(class)
    requested_at = parse_requested(Floki.attribute(html, "data-requested"))

    ##
    ## Name, price, request_status and country.
    ##
    # Find the link to the popup dialog to request/note.
    [{_, name_attributes, [_name]}] = Floki.find(html, "a.item-name")

    # Parse the javascript call *sigh*.
    {:ok, tree} = name_attributes
    |> Enum.into(%{})
    |> Map.get("ng-click")
    |> MinimalJsCallParser.parse

    # Pull out the arguments.
    {:call, _obj, _func, args} = Enum.at(tree, 0)
    {:int, remote_id} = Enum.at(args, 1)
    {:string, name} = Enum.at(args, 2)
    {:string, country} = Enum.at(args, 3)
    {:string, price} = Enum.at(args, 4)
    {:string, request_status} = Enum.at(args, 5)
    # Quotes remain escaped which is a pain.
    name = String.replace(name, "\\'", "'")
    raw_name = name
    # Price to int
    {price, _} = Float.parse(price)

    {state, name} = parse_state(country, name)
    {is_new, name} = parse_is_new(name)
    {is_immortal, name} = parse_is_immortal(name)
    {size, name} = parse_size(name)
    {notes, rating} = parse_notes(Floki.find(html, "div.notes"))

    %BevagerScraper.Rum{
      remote_id: remote_id,
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

  def list_from_html(html) do
    elements = Floki.find(html, "tr.item")
    for element <- elements do
      BevagerScraper.Rum.new_from_floki(element)
    end
  end
end
