defmodule Main do
  @moduledoc """
  BevagerScraper scraps bevager.com

  --email=<bevager email>
  --password=<bevager password>
  --file=<where to put html>

  'reload' to download from bevager.
  'dump' to parse and dump the html file as structs
  'sql' to parse and dump the parse html file as sql

  Otherwise it just dumps the a list of rums.
  """

  def main(args) do
    args |> parse_args |> process
  end

  def help() do
    IO.puts @moduledoc
    System.halt(0)
  end

  def process({options, ["reload"], _invalid}) do
    html = BevagerScraper.login(options[:email], options[:password])
    |> BevagerScraper.load_rum_list_html
    File.write(options[:file], html)
  end

  def process({options, ["dump"], _invalid}) do
    {:ok, html} = File.read(options[:file])
    user = BevagerScraper.User.new_from_html(html)
    IO.inspect user
    for rum <- BevagerScraper.Rum.list_from_html(html) do
      IO.inspect rum
    end
  end

  def process({options, ["user"], _invalid}) do
    {:ok, html} = File.read(options[:file])
    user = BevagerScraper.User.new_from_html(html)
    IO.inspect user
  end

  def process({options, ["sql"], _invalid}) do
    {:ok, html} = File.read(options[:file])
    for rum <- BevagerScraper.Rum.list_from_html(html) do
      IO.write([BevagerScraper.Utils.to_upsert(rum), "\n"])
    end
  end

  defp parse_args(args) do
    {options, args, invalid} = OptionParser.parse(
      args,
      strict: [
        email: :string,
        password: :string,
        help: :boolean,
        file: :string
      ],
      aliases: [h: :help]
    )
    case options[:help] do
      true  -> help()
      _ -> {options, args, invalid}
    end
  end
end
