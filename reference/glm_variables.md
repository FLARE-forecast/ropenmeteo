# Get set of variables required for the GLM model

Get set of variables required for the GLM model

## Usage

``` r
glm_variables(product, time_step)
```

## Arguments

- product:

  api type: climate, forecast, ensemble_forecast, historical,
  seasonal_forecast

- time_step:

  model and time-step: hourly, 6hourly, daily

## Value

a vector of variables requires by the GLM model; the vector can be used
in the `variables` argument in the API function calls (e.g.,
`get_ensemble_forecast`).

## Examples

``` r
glm_variables(product = "ensemble_forecast", time_step = "hourly")
#> [1] "relative_humidity_2m" "precipitation"        "wind_speed_10m"      
#> [4] "cloud_cover"          "temperature_2m"       "shortwave_radiation" 
#> [7] "surface_pressure"    
```
