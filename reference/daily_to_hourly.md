# Convert daily climate projections to hourly time-step

Convert daily climate projections to hourly time-step

## Usage

``` r
daily_to_hourly(df, latitude, longitude)
```

## Arguments

- df:

  data frame output by
  [`get_climate_projections()`](http://flare-forecast.org/ropenmeteo/reference/get_climate_projections.md)
  that has daily values for the variable

- latitude:

  latitude degree north

- longitude:

  longitude degree east

## Value

data frame with an hourly time step

## Examples

``` r
if (FALSE) { # interactive()
get_climate_projections(
latitude = 37.30,
longitude = -79.83,
start_date = Sys.Date(),
end_date = Sys.Date() + lubridate::years(1),
model = "EC_Earth3P_HR",
variables = glm_variables(product = "climate_projection", time_step = "daily")) |>
daily_to_hourly(latitude = 37.30, longitude = -79.83)
}
```
