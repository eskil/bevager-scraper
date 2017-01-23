# BevagerScraper

This is a library to scrape bevager data using an existing bevager
login. It only provides read access at this time.

It does some specific parsing that fits my style of leaving rum
tasting notes plus the naming of the rum.

  * If the note ends in _"... x[.y]*"_, x.y is parsed as a rating.
  * If the name starts with _"*"_, it's considered a new rum.
  * If name contains _"Immortal"_, it's considered an immortal rum.
  * It tries to extract the _1oz/2oz_ from the name.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `bevager_scraper` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bevager_scraper, git: "git@github.com:eskil/bevager-scraper.git"}]
    end
    ```

    And ensure `:httpotion` is started in your apps

    ```elixir
    def application do
      [mod: {YourApp, []},
       applications: [..., :httpotion]]
    end
    ```

## CLI

   ```shell
   mix deps.get
   mix escript.build
   ./bevager_scraper --email=<email> --password=<password> --file=rums.html reload
   ./bevager_scraper --file=rums.html dump
   ```

## As libary

   ```elixir
   elements = Bevager.login(user.email, user.bevager_password)
   |> Bevager.load_rum_list_html
   |> Floki.find("tr.item")
   for element <- elements do
     bevager = Bevager.Rum.new_from_floki(element)
     IO.inspect bevager
   end
   ```

First command downloads the html from bevager. Second scrapes it and for now just dumps the rums.

   ```
   %Bevager.Rum{country: "Guadeloupe", is_historic: true, is_immortal: false,
     is_new: false, name: "Domaine de Séverin", notes: nil, price: 12, rating: nil,
     raw_name: "Domaine de Séverin - 1 oz", request_status: "M.C",
     requested_at: ~N[2009-12-08 00:00:00], size: 1}
   %Bevager.Rum{country: "Antigua and Barbuda", is_historic: true,
     is_immortal: false, is_new: false, name: "English Harbour 10 year",
     notes: "Raisins, \"something scribbles\" but sweet,", price: 26, rating: 3.0,
     raw_name: "English Harbour 10 year", request_status: "M.C",
     requested_at: ~N[2009-12-08 00:00:00], size: 2}
   ```

## SQL

Bevager-scraper has a very simply dump-to-sql upsert feature;

   ```
   ./bevager_scraper --file=rums.html sql
   ```

Which generates SQL ala

   ```
   INSERT INTO rums.basic_rums (name, raw_name, request_status, notes, country, requested_at, rating, size, price, is_new, is_historic, is_immortal) VALUES ("Domaine de Séverin", "Domaine de Séverin - 1 oz", "M.C", NULL, "Guadeloupe", "2009-12-08 00:00:00", NULL, 1, 12, false, true, false)
ON DUPLICATE KEY UPDATE
request_status="M.C", notes=NULL, requested_at="2009-12-08 00:00:00", is_historic=true, is_immortal=false, is_new=false, rating=NULL, size=1, price=12;

   INSERT INTO rums.basic_rums (name, raw_name, request_status, notes, country, requested_at, rating, size, price, is_new, is_historic, is_immortal) VALUES ("English Harbour 10 year", "English Harbour 10 year", "M.C", "Raisins, \"something scribbles\" but sweet,", "Antigua and Barbuda", "2009-12-08 00:00:00", 3.0, 2, 26, false, true, false)
   ON DUPLICATE KEY UPDATE
   request_status="M.C", notes="Raisins, \"something scribbles\" but sweet,", requested_at="2009-12-08 00:00:00", is_historic=true, is_immortal=false, is_new=false, rating=3.0, size=2, price=26;
   ```

Which will work with the following table definition.

   ```
   CREATE TABLE IF NOT EXISTS rums.basic_rums (
     `id` int(11) NOT NULL AUTO_INCREMENT,
     `name` VARCHAR(256) NOT NULL,
     `raw_name` VARCHAR(256) NOT NULL,
     `price` INT(4),
     `is_new` BOOL DEFAULT FALSE,
     `is_historic` BOOL DEFAULT FALSE,
     `is_immortal` BOOL DEFAULT FALSE,
     requested_at DATETIME DEFAULT NULL,
     request_status VARCHAR(20) DEFAULT NULL,
     `notes` VARCHAR(1024) DEFAULT NULL,
     `country` VARCHAR(128),
     `rating` FLOAT(2, 1) DEFAULT NULL,
     `size` INT(4),
     PRIMARY KEY (`id`),
     UNIQUE KEY `name` (`name`)
   );
   ```
