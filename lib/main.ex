defmodule Main do
  @moduledoc """
  BevagerScraper scraps bevager.com

  --email=<bevager email>
  --password=<bevager password>
  --file=<where to put html>
  reload to download from bevager.

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
    html = Bevager.login(options[:email], options[:password])
    |> Bevager.load_rum_list_html
    File.write(options[:file], html)
  end

  def process({options, _args, _invalid}) do
    {:ok, html} = File.read(options[:file])
    rums = Floki.find(html, "tr.item")
    for rum <- rums do
      IO.inspect Bevager.Rum.new_from_floki(rum)
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
      true  -> help
      _ -> {options, args, invalid}
    end
  end
end
