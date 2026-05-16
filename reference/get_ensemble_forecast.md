# Download point-level ensemble weather forecast using open-meteo API

Download point-level ensemble weather forecast using open-meteo API

## Usage

``` r
get_ensemble_forecast(
  latitude,
  longitude,
  site_id = NULL,
  forecast_days,
  past_days,
  model = "gfs_seamless",
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

- forecast_days:

  number of forecast days (max 35)

- past_days:

  number of past days to include (max 92)

- model:

  ensemble model id. Default `"gfs_seamless"`. Common options:
  `"gfs_seamless"`, `"icon_seamless_eps"`, `"ecmwf_ifs025"`,
  `"ecmwf_aifs025"`, `"gem_global"`, `"bom_access_global"`,
  `"ukmo_global_20km"`. Note: `ecmwf_ifs025` does not include shortwave
  radiation. See <https://open-meteo.com/en/docs/ensemble-api> for the
  full list.

- variables:

  character vector of variable names. See
  <https://open-meteo.com/en/docs/ensemble-api> for the full list.

## Value

data frame with the results from the call to the open-meteo API. The
data frame is in a long format and has the following columns:
"datetime", "reference_datetime", "site_id", "model_id", "ensemble",
"variable", "prediction","unit".

## Examples

``` r
if (FALSE) { # interactive()
get_ensemble_forecast(
latitude = 37.30,
longitude = -79.83,
forecast_days = 7,
past_days = 2,
model = "gfs_seamless",
variables = c("temperature_2m"))

}
```
