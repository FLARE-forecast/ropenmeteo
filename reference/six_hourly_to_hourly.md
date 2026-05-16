# Convert 6 hour seasonal forecast to hourly time-step

Convert 6 hour seasonal forecast to hourly time-step

## Usage

``` r
six_hourly_to_hourly(df, latitude, longitude, use_solar_geom = TRUE)
```

## Arguments

- df:

  data frame with 6-hour time step

- latitude:

  latitude degree north

- longitude:

  long longitude degree east

- use_solar_geom:

  use solar geometry to determine hourly solar radiation

## Value

data frame with an hourly time step

## Examples

``` r
if (FALSE) { # interactive()
get_seasonal_forecast(
latitude = 37.30,
longitude = -79.83,
forecast_days = 30,
past_days = 5,
variables = glm_variables(product = "seasonal_forecast",
                         time_step = "6hourly")) |>
six_hourly_to_hourly(
    latitude = 37.30,
    longitude = -79.83,
    use_solar_geom = TRUE)
}
```
