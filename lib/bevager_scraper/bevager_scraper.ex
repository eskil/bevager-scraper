defmodule BevagerScraper do
  defstruct cookie: nil

  def login(email, password) do
    {:ok, body} = Poison.encode(%{login: %{email: email, password: password, programId: 1}})
    headers = ["Content-Type": "application/json", "referer": " https://app.craftable.com/brg?rewardsGroupName=rumbustion"]
    response = HTTPotion.post("https://app.craftable.com/brgLogin", [body: body, headers: headers])
    IO.puts String.duplicate("-", 72)
    IO.puts inspect(response)
    cookie = response.headers["set-cookie"]
    %BevagerScraper{cookie: cookie}
  end

  # Get user info
  # curl 'https://app.craftable.com/brgUsers?rewardsGroupName=rumbustion&_=1624758993714' \
  # -H 'authority: app.craftable.com' \
  # -H 'sec-ch-ua: " Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"' \
  # -H 'director-brand-id: 0' \
  # -H 'store-id: 0' \
  # -H 'sec-ch-ua-mobile: ?0' \
  # -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36' \
  # -H 'application-code: 0' \
  # -H 'accept: application/json, text/javascript, */*; q=0.01' \
  # -H 'x-requested-with: XMLHttpRequest' \
  # -H 'sec-fetch-site: same-origin' \
  # -H 'sec-fetch-mode: cors' \
  # -H 'sec-fetch-dest: empty' \
  # -H 'referer: https://app.craftable.com/brg?rewardsGroupName=rumbustion' \
  # -H 'accept-language: en-US,en;q=0.9' \
  # -H 'cookie: _ga=GA1.2.1977348425.1624758990; _gid=GA1.2.766475812.1624758990; __stripe_mid=cd23534e-464e-48cc-97fe-d433220c716809881d; __stripe_sid=d837d31c-cbc9-411f-8532-1b3a5965a3d563ac6e; __zlcmid=14nk8TiWrhgyG4t; CRAFTABLE_SESSION=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIiLCJ1c2VyRW1haWwiOiJFU0tJTEBFU0tJTC5PUkciLCJleHAiOjE2MjQ3NzcxMjksInVzZXJJZCI6MTM5LCJpYXQiOjE2MjQ3NTkxMjksInByb2dyYW1JZCI6MX0.OdhRCGZgeHFDQezVddSHJUQXiBiMUk72fr2ayaQkMgbfPKMTrjaoj94OXgaTE8_RAHm4bpmXDUJaPmqpWy2ZlQ' \
  # --compressed


  ## Get rum list
  # curl 'https://app.craftable.com/brgItems?rewardsGroupName=rumbustion&_=1624758993715' \
  # -H 'authority: app.craftable.com' \
  # -H 'sec-ch-ua: " Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"' \
  # -H 'director-brand-id: 0' \
  # -H 'store-id: 0' \
  # -H 'sec-ch-ua-mobile: ?0' \
  # -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36' \
  # -H 'application-code: 0' \
  # -H 'accept: application/json, text/javascript, */*; q=0.01' \
  # -H 'x-requested-with: XMLHttpRequest' \
  # -H 'sec-fetch-site: same-origin' \
  # -H 'sec-fetch-mode: cors' \
  # -H 'sec-fetch-dest: empty' \
  # -H 'referer: https://app.craftable.com/brg?rewardsGroupName=rumbustion' \
  # -H 'accept-language: en-US,en;q=0.9' \
  # -H 'cookie: _ga=GA1.2.1977348425.1624758990; _gid=GA1.2.766475812.1624758990; __stripe_mid=cd23534e-464e-48cc-97fe-d433220c716809881d; __stripe_sid=d837d31c-cbc9-411f-8532-1b3a5965a3d563ac6e; __zlcmid=14nk8TiWrhgyG4t; CRAFTABLE_SESSION=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIiLCJ1c2VyRW1haWwiOiJFU0tJTEBFU0tJTC5PUkciLCJleHAiOjE2MjQ3NzcxMjksInVzZXJJZCI6MTM5LCJpYXQiOjE2MjQ3NTkxMjksInByb2dyYW1JZCI6MX0.OdhRCGZgeHFDQezVddSHJUQXiBiMUk72fr2ayaQkMgbfPKMTrjaoj94OXgaTE8_RAHm4bpmXDUJaPmqpWy2ZlQ' \
  # --compressed

  def load_rum_list_html(%BevagerScraper{cookie: cookie}) do
    response = HTTPotion.get("https://app.craftable.com/brg?rewardsGroupName=rumbustion",
      [headers: [cookie: cookie], timeout: 20000, follow_redirects: true])
    IO.puts String.duplicate("-", 72)
    IO.puts inspect(response)
    response.body
  end
end
