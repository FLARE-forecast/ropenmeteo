# Download point-level historical weather (ERA5) using open-meteo API

Download point-level historical weather (ERA5) using open-meteo API

## Usage

``` r
get_historical_weather(
  latitude,
  longitude,
  site_id = NULL,
  start_date,
  end_date,
  variables = c("relative_humidity_2m", "precipitation", "wind_speed_10m", "cloud_cover",
    "temperature_2m", "shortwave_radiation")
)
```

## Arguments

- latitude:

  latitude in decimal degrees north

- longitude:

  longitude in decimal degrees east

- site_id:

  optional site label added to output; defaults to "latitude_longitude"

- start_date:

  earliest date requested (ISO format "YYYY-MM-DD"). ERA5 is available
  from 1940-01-01 to present.

- end_date:

  latest date requested (ISO format "YYYY-MM-DD"). Note that ERA5 has a
  processing delay of approximately 5 days.

- variables:

  character vector of variable names. See
  <https://open-meteo.com/en/docs/historical-weather-api> for the full
  list.

## Value

data frame in long format with columns: datetime, site_id, model_id,
variable, prediction, unit. model_id is always "ERA5".

## Examples

``` r
if (FALSE) { # interactive()
get_historical_weather(
latitude = 37.30,
longitude = -79.83,
start_date = "2023-01-01",
end_date = Sys.Date(),
variables = c("temperature_2m"))
}
```
