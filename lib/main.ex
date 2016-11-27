defmodule Main do
  @moduledoc """
  BevagerScraper scraps bevager.com
  """

  def main(args) do
    args |> parse_args |> process
  end

  def help() do
    IO.puts @moduledoc
    System.halt(0)
  end

  def parse_requested([""]) do
    nil
  end

  def parse_requested([s]) do
    s
  end

  def parse_historic([class]) do
    "historic-item" in String.split(class)
  end

  def process({options, _args, _invalid}) do
    rums = Bevager.login(options[:email], options[:password])
    |> Bevager.load_rum_list_html
    |> Floki.find("tr.item")
    for rum <- rums do
      IO.puts "============================================================="
      IO.inspect rum
      IO.puts "............................................................."
      class = Floki.attribute(rum, "class")
      requested = parse_requested(Floki.attribute(rum, "data-requested"))
      is_historic = parse_historic(class)
      IO.puts "Is historic"
      IO.inspect is_historic
      IO.puts "Was requested"
      IO.inspect requested
      IO.puts "Name"
      IO.inspect Floki.find(rum, "a.item-name")
      IO.puts "Notes"
      IO.inspect Floki.find(rum, "div.notes")
      IO.puts "Country"
      IO.inspect Floki.find(rum, "div:not(.notes)")
      IO.puts "Price"
      IO.inspect Floki.find(rum, "td[class=\"\"]")

      for child <- Floki.find(rum, "td") do
        IO.puts "-----------------------------------------------------"
        {tag, attrs, contents} = child
        IO.inspect attrs
        IO.inspect contents
      end
    end
  end

  defp parse_args(args) do
    {options, args, invalid} = OptionParser.parse(
      args,
      strict: [email: :string, password: :string, help: :boolean],
      aliases: [h: :help]
    )
    case options[:help] do
      true  -> help
      _ -> {options, args, invalid}
    end
  end
end
