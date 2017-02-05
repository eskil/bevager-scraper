defmodule BevagerScraper.User do
  defstruct level: nil

  def new_from_html(html) do
    elements = Floki.find(html, "div.row")
    {"div", _class, elements} = List.first(elements)
    {:ok, {"div", _fluff, level_elements}} = Enum.fetch(elements, 0)
    {:ok, level_string} = Enum.fetch(level_elements, 5)
    level = String.trim(level_string)

    %BevagerScraper.User{
      level: level
    }
  end
end
