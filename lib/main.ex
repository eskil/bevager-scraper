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

  def process({options, _args, _invalid}) do
    session = Bevager.login(options[:email], options[:password])
    IO.inspect session
    Bevager.load_rum_list_html(session)
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
