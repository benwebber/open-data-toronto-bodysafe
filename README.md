# BodySafe

This is a [Git scraping](https://simonwillison.net/series/git-scraping/) mirror of Toronto's [BodySafe](https://open.toronto.ca/dataset/bodysafe/) data.

> BodySafe is Toronto Public Health's safety program that inspects personal service settings (PSS) including hairstyling and barbering, tattooing, micropigmentation, ear and body piercing, injectable personal services, electrolysis, manicure, pedicure, and aesthetic services.

## Database

This project builds an SQLite database of the data, as well as a [Datasette](https://datasette.io/) image to explore the data.
Download the [latest version](https://github.com/benwebber/open-data-toronto-bodysafe/releases/latest) of database from the [releases](https://github.com/benwebber/open-data-toronto-bodysafe/releases) page.

Run the latest published image with Docker:

```
docker run -p 8000:8000 ghcr.io/benwebber/open-data-toronto-bodysafe:latest
```

Or build the database locally and run the image with Docker Compose:

```
make bodysafe.db
docker compose up
```

## Licence

The City of Toronto makes this data available under the terms of [Open Government Licence – Toronto](https://open.toronto.ca/open-data-licence/).
