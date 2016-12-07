# BevagerScraper

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `bevager_scraper` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bevager_scraper, "~> 0.1.0"}]
    end
    ```

  2. Ensure `bevager_scraper` is started before your application:

    ```elixir
    def application do
      [applications: [:bevager_scraper]]
    end
    ```

## CLI

   ```mix deps.get
   mix escript.build
   ./bevager_scraper --email=<email> --password=<password> --file=rums.html reload
   ./bevager_scraper --file=rums.html
   ```

First command downloads the html from bevager. Second scrapes it and for now just dumps the rums.

   ```
   %Bevager.Rum{country: "Saint Lucia", is_historic: false, is_new: false,
   name: "St. Lucia Distillers 1931 Batch #3",
   notes: "Very smooth nose, also smooth slightly raisiny palate. Very good.",
   price: 26, rating: 4.0, request_status: nil,
   requested_at: ~N[2016-11-22 17:20:00]}
  %Bevager.Rum{country: "Regional Blends", is_historic: false, is_new: false,
   name: "Prof. Cornelius Ampleforth's Rumbullion! Spiced Navy Strength Rum 1 oz",
   notes: "This is a Fairly anis flavoured spiced rum that's very strong too. Not a winning mix.",
   price: 22, rating: 1.0, request_status: nil,
   requested_at: ~N[2016-11-22 17:25:00]}
  %Bevager.Rum{country: "Barbados", is_historic: false, is_new: true,
   name: "Bristol Classic Fine Barbados Rum 2004 Foursquare 43%",
   notes: "Pleasant sweet nose. Very nice taste with hint if dark sweetness to it.",
   price: 70, rating: 4.0, request_status: nil,
    requested_at: ~N[2016-11-28 17:09:00]}
   ```
