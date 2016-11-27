defmodule Bevager do
  defstruct cookies: nil

  def login(email, password) do
    {:ok, body} = Poison.encode(%{email: email, password: password, programId: 1, referer: "/brg", "rewardsGroupName": "rumbustion"})
    headers = [{"Content-Type", "application/json"}]
    {:ok, response} = HTTPoison.post("https://www.bevager.com/brg/login", body, headers)
    cookies = :hackney.cookies(response.headers)
    %Bevager{cookies: cookies}
  end

  def load_rum_list_html(%Bevager{cookies: cookies}) do
    [c] = for {_, v} <- cookies do v end
    ac = [List.first(c)]
    IO.inspect ac
    r = HTTPoison.get("https://www.bevager.com/brg/home?rewardsGroupName=rumbustion",
                      %{},
                       hackney: [cookie: ac, follow_redirect: true, force_redirect: true])
    IO.inspect r
  end

end
