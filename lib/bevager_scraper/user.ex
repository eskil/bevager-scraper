defmodule BevagerScraper.User do
  defstruct level: nil, name: nil, rums: nil, immortals: nil

  def new_from_html(html) do
    elements = Floki.find(html, "div.row")
    {"div", _class, elements} = List.first(elements)
    {:ok, {"div", _fluff, level_elements}} = Enum.fetch(elements, 0)
    {:ok, name_string} = Enum.fetch(level_elements, 1)
    {:ok, level_string} = Enum.fetch(level_elements, 5)
    level = String.trim(level_string)
    name = String.trim_trailing(String.trim(name_string), "|")

    {:ok, {"div", _fluff, count_elements}} = Enum.fetch(elements, 1)
    {:ok, rums_string} = Enum.fetch(count_elements, 1)
    {:ok, immortals_string} = Enum.fetch(count_elements, 4)
    rums = String.trim(rums_string)
    immortals = String.trim(immortals_string)

    %BevagerScraper.User{
      level: level,
      name: name,
      rums: rums,
      immortals: immortals
    }
  end
end
