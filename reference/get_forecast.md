# Download point-level weather forecast using open-meteo API

Returns the best-match single forecast (not ensemble) for a location.
Use
[`get_ensemble_forecast()`](http://flare-forecast.org/ropenmeteo/reference/get_ensemble_forecast.md)
for probabilistic ensemble output.

## Usage

``` r
get_forecast(
  latitude,
  longitude,
  site_id = NULL,
  forecast_days,
  past_days,
  model = "generic",
  variables = c("temperature_2m")
)
```

## Arguments

- latitude:

  latitude in decimal degrees north

- longitude:

  longitude in decimal degrees east

- site_id:

  optional site label added to output; defaults to "latitude_longitude"

- forecast_days:

  number of forecast days (max 16)

- past_days:

  number of past days to include (max 92)

- model:

  weather model id. Default `"generic"` selects the best available model
  for each location. Other options: `"gfs"`, `"ecmwf"`, `"meteofrance"`,
  `"dwd"`, `"gem"`, `"jma"`, `"metno"`, `"kma"`, `"bom"`, `"ukmo"`. See
  <https://open-meteo.com/en/docs> for details.

- variables:

  character vector of variable names. See
  <https://open-meteo.com/en/docs> for the full list.

## Value

data frame in long format with columns: datetime, reference_datetime,
site_id, model_id, variable, prediction, unit

## Examples

``` r
if (FALSE) { # interactive()
get_forecast(latitude = 37.30,
            longitude = -79.83,
            forecast_days = 7,
            past_days = 2,
           model = "generic",
            variables = c("temperature_2m"))
}
```
