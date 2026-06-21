ropenmeteo
================

<!-- badges: start -->

[![R-CMD-check](https://github.com/FLARE-forecast/RopenMeteo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/FLARE-forecast/RopenMeteo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Wrappers for application programming interfaces on the Open-Meteo
project. Open-Meteo is an amazing project that streamlines access to a
range of publicly available historical and forecast meteorology data from
agencies across the world. The free access tier allows for 10,000 API
calls per day. The paid tiers increase the number of daily API calls.
Learn more about the Open-Meteo project at their website
(<https://open-meteo.com>) and consider supporting their efforts.

Open-Meteo citation: Zippenfenig, Patrick. (2023). Open-Meteo.com
Weather API (0.2.69). Zenodo. <https://doi.org/10.5281/zenodo.8112599>

The package includes additional functionality to facilitate use in
mechanistic environmental/ecological models. This includes the
calculation of longwave radiation (not provided through the API) from
air temperature and cloud cover, the writing of output to the format
required by the General Lake Model (GLM), and the conversion to the
standard used in the NEON Ecological Forecasting Challenge that is run
by the Ecological Forecasting Initiative Research Coordination Network.

The package uses a long format standard with the following columns:

- `datetime` = date and time of forecasted value
- `reference_datetime` = the date and time of the beginning of the
  forecast (horizon = 0). Does not apply to historical weather.
- `site_id` = column to identify site location. If null in function call
  it defaults to latitude_longitude
- `model_id` = id of model that generated the forecast
- `ensemble` = ensemble member number (only for ensemble weather and
  seasonal forecasts)
- `variable` = forecasted variable
- `prediction` = forecasted value
- `unit` = units of the variable

## Install

Install the development version from GitHub with:

    devtools::install_github("FLARE-forecast/ropenmeteo")

## Quick Start

``` r
library(ropenmeteo)
library(ggplot2)
library(dplyr)
```

The simplest call returns a best-match single forecast for any location
on Earth using `get_forecast()` (max 16 days, all variables returned in
m/s, °C, mm, etc.):

``` r
df <- get_forecast(
  latitude = 37.30,
  longitude = -79.83,
  forecast_days = 7,
  past_days = 2,
  model = "generic",
  variables = c("temperature_2m", "wind_speed_10m"))
head(df)
```

    ## # A tibble: 6 × 7
    ##   datetime            reference_datetime  site_id      model_id variable
    ##   <dttm>              <dttm>              <chr>        <chr>    <chr>
    ## 1 2024-08-25 00:00:00 2024-08-27 00:00:00 37.3_-79.83 generic  temperature_2m
    ## 2 2024-08-25 01:00:00 2024-08-27 00:00:00 37.3_-79.83 generic  temperature_2m
    ## 3 2024-08-25 02:00:00 2024-08-27 00:00:00 37.3_-79.83 generic  temperature_2m
    ## 4 2024-08-25 03:00:00 2024-08-27 00:00:00 37.3_-79.83 generic  temperature_2m
    ## 5 2024-08-25 04:00:00 2024-08-27 00:00:00 37.3_-79.83 generic  temperature_2m
    ## 6 2024-08-25 05:00:00 2024-08-27 00:00:00 37.3_-79.83 generic  temperature_2m
    ## # ℹ 2 more variables: prediction <dbl>, unit <chr>

For probabilistic forecasts use `get_ensemble_forecast()` (max 35 days,
30–51 ensemble members depending on model):

``` r
df <- get_ensemble_forecast(
  latitude = 37.30,
  longitude = -79.83,
  forecast_days = 7,
  past_days = 2,
  model = "gfs_seamless",
  variables = c("temperature_2m"))
```

The long format output is straightforward to visualize with ggplot2:

``` r
df |>
  mutate(variable = paste(variable, unit)) |>
  ggplot(aes(x = datetime, y = prediction, color = ensemble)) +
  geom_line() +
  geom_vline(aes(xintercept = reference_datetime)) +
  facet_wrap(~variable, scale = "free", ncol = 2)
```

## Examples

See the [vignette](vignettes/example_usage.Rmd) for full examples
covering ensemble forecasts, historical weather, seasonal forecasts,
climate projections, GLM integration, and the EFI standard.
