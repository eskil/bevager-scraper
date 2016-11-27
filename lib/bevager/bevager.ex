defmodule Bevager do
  defstruct cookie: nil

  def login(email, password) do
    {:ok, body} = Poison.encode(%{email: email, password: password, programId: 1, referer: "/brg", "rewardsGroupName": "rumbustion"})
    headers = [{"Content-Type", "application/json"}]
    response = HTTPotion.post("https://www.bevager.com/brg/login", [body: body, headers: headers])
    cookie = response.headers["set-cookie"]
    %Bevager{cookie: cookie}
  end

  def load_rum_list_html(%Bevager{cookie: cookie}) do
    r = HTTPotion.get("https://www.bevager.com/brg/home?rewardsGroupName=rumbustion",
                      [headers: [cookie: cookie], timeout: 20000, follow_redirects: true])
    r.body
  end
end
