# Download point-level climate projections using open-meteo API

Returns daily climate projections from high-resolution CMIP6 models
covering 1950–2050. Use
[`daily_to_hourly()`](http://flare-forecast.org/ropenmeteo/reference/daily_to_hourly.md)
to downscale to hourly resolution.

## Usage

``` r
get_climate_projections(
  latitude,
  longitude,
  site_id = NULL,
  start_date,
  end_date,
  model = "EC_Earth3P_HR",
  variables = c("temperature_2m_mean")
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

  start of the date range (ISO format "YYYY-MM-DD"). Data available from
  1950-01-01.

- end_date:

  end of the date range (ISO format "YYYY-MM-DD"). Projections available
  through 2050-12-31.

- model:

  climate model id. Default `"EC_Earth3P_HR"`. All seven models:
  `"CMCC_CM2_VHR4"`, `"FGOALS_f3_H"`, `"HiRAM_SIT_HR"`,
  `"MRI_AGCM3_2_S"`, `"EC_Earth3P_HR"`, `"MPI_ESM1_2_XR"`,
  `"NICAM16_8S"`. See <https://open-meteo.com/en/docs/climate-api> for
  details.

- variables:

  character vector of daily variable names (use `_mean`, `_max`, `_min`,
  or `_sum` suffixes as appropriate, e.g. `"temperature_2m_mean"`). See
  <https://open-meteo.com/en/docs/climate-api> for the full list.

## Value

data frame in long format with columns: datetime, site_id, model_id,
variable, prediction, unit. Output is at daily resolution.

## Examples

``` r
if (FALSE) { # interactive()

get_climate_projections(
latitude = 37.30,
longitude = -79.83,
start_date = Sys.Date(),
end_date = Sys.Date() + lubridate::years(1),
model = "EC_Earth3P_HR",
variables = c("temperature_2m_mean"))
}
```
