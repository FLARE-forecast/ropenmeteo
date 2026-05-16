# Download point-level seasonal weather forecast using open-meteo API

Returns 6-hourly ensemble forecasts from ECMWF seasonal models. The
seamless model uses EC46 for the first 46 days and SEAS5 for up to 7
months ahead.

## Usage

``` r
get_seasonal_forecast(
  latitude,
  longitude,
  site_id = NULL,
  forecast_days,
  past_days,
  model = "ecmwf_seasonal_seamless",
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

  number of forecast days. EC46 supports up to 46 days; SEAS5 and the
  seamless blend support up to ~214 days (7 months).

- past_days:

  number of past days to include

- model:

  seasonal model id. Default `"ecmwf_seasonal_seamless"`. Other options:
  `"ecmwf_seas5"`, `"ecmwf_ec46"`. See
  <https://open-meteo.com/en/docs/seasonal-forecast-api> for details.

- variables:

  character vector of variable names. See
  <https://open-meteo.com/en/docs/seasonal-forecast-api> for the full
  list.

## Value

data frame in long format with columns: datetime, reference_datetime,
site_id, model_id, ensemble, variable, prediction, unit.

## Examples

``` r
if (FALSE) { # interactive()

get_seasonal_forecast(
latitude = 37.30,
longitude = -79.83,
forecast_days = 30,
past_days = 5,
variables = glm_variables(product = "seasonal_forecast",
                         time_step = "6hourly"))
}
```
