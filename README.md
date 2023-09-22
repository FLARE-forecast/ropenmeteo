RopenMeteo
================

<!-- badges: start -->

[![R-CMD-check](https://github.com/FLARE-forecast/RopenMeteo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/FLARE-forecast/RopenMeteo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

R wrappers for APIs on Open-Meteo project. The Open-Meteo is a amazing
project that streamlines the access to a range of publicly historical
and forecasted meteorology data from agencies across the world. The free
access tier allows for 10,000 API calls per day. The paid tiers increase
the number of daily API calls (support for paid APIs in this package is
pending). Learn more about the Open-Meteo project at their website
(\[<https://open-meteo.com>\]) and consider supporting their efforts.

Open-Meteo citation: Zippenfenig, Patrick. (2023). Open-Meteo.com
Weather API (0.2.69). Zenodo. <https://doi.org/10.5281/zenodo.8112599>

The package includes additional functionally to facilitate the use in
mechanistic environmental/ecological models. This includes the
calculation of longwave radiation (not provided through the API) from
air temperature and cloud cover, the writing of output to the format
required by the General Lake Model (GLM), and the conversion to the
standard used in the NEON Ecological Forecasting Challenge that is run
by the Ecological Initiative Research Coordination Network
(\[<https://neon4cast.org>\]). Future functionally includes the temporal
downscaling of the daily climate projection output and the 6-hourly
seasonal forecast to the hourly time step.

The package uses a long format standard with the following columns

    datetime = date and time of forecasted value
    reference_datetime = the date and time of the beginning of the forecast (horizon = 0). Does not apply to historical weather.
    model_id = id of model that generated the forecast
    ensemble = ensemble member number (only for ensemble weather and seasonal forecasts)
    variable = forecasted variable
    prediction = forecasted value
    unit = units of the variable

## Install

``` r
remotes::install_github("FLARE-forecast/RopenMeteo")
```

``` r
library(tidyverse)
```

## Weather forecasts

The open-meteo project combines the the best models for each location
across the globe to provide the best possible forecast. open-meteo
defines this as `model = "generic"`.

\[<https://open-meteo.com/en/docs>\]

``` r
df <- RopenMeteo::get_forecast(latitude = 37.30,
                               longitude = -79.83,
                               forecast_days = 7, 
                               past_days = 2, 
                               model = "generic",
                               variables = c("temperature_2m"))
head(df)
```

    ## # A tibble: 6 × 6
    ##   datetime            reference_datetime  model_id variable     prediction unit 
    ##   <dttm>              <dttm>              <chr>    <chr>             <dbl> <chr>
    ## 1 2023-09-20 00:00:00 2023-09-22 00:00:00 generic  temperature…       16.8 °C   
    ## 2 2023-09-20 01:00:00 2023-09-22 00:00:00 generic  temperature…       15.3 °C   
    ## 3 2023-09-20 02:00:00 2023-09-22 00:00:00 generic  temperature…       16.2 °C   
    ## 4 2023-09-20 03:00:00 2023-09-22 00:00:00 generic  temperature…       15.5 °C   
    ## 5 2023-09-20 04:00:00 2023-09-22 00:00:00 generic  temperature…       14.9 °C   
    ## 6 2023-09-20 05:00:00 2023-09-22 00:00:00 generic  temperature…       14.3 °C

``` r
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction)) + 
  geom_line(color = "#F8766D") + 
  geom_vline(aes(xintercept = reference_datetime)) + 
  facet_wrap(~variable, scale = "free")
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

## Ensemble Weather Forecasts

Ensemble forecasts from individual models are available.

\[<https://open-meteo.com/en/docs/ensemble-api>\]

``` r
df <- RopenMeteo::get_ensemble_forecast(
  latitude = 37.30,
  longitude = -79.83,
  forecast_days = 7,
  past_days = 2,
  model = "gfs_seamless",
  variables = c("temperature_2m"))
head(df)
```

    ## # A tibble: 6 × 7
    ##   datetime            reference_datetime  model_id  ensemble variable prediction
    ##   <dttm>              <dttm>              <chr>     <chr>    <chr>         <dbl>
    ## 1 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 00       tempera…       14  
    ## 2 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 01       tempera…       14.3
    ## 3 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 02       tempera…       14.5
    ## 4 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 03       tempera…       14.2
    ## 5 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 04       tempera…       14  
    ## 6 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 05       tempera…       14.2
    ## # ℹ 1 more variable: unit <chr>

``` r
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction, color = ensemble)) + 
  geom_line() + 
  geom_vline(aes(xintercept = reference_datetime)) + 
  facet_wrap(~variable, scale = "free", ncol = 2)
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Options for models and variables are at
<https://open-meteo.com/en/docs/ensemble-api>

Note that `ecmwf_ifs04` does not include solar radiation.

List of global model ids:

    icon_seamless, icon_global, gfs_seamless, gfs025, gfs05, ecmwf_ifs04, gem_global

### Use with the General Lake Model

We have included functions that allow the output to be used with the
General Lake Model (\[<https://doi.org/10.5194/gmd-12-473-2019>\]).
Since the open-meteo models do not include longwave radiation, the
package provides a function to calculate it from the cloud cover and air
temperature.

GLM requires a set of variables that are provided

``` r
df <- RopenMeteo::get_ensemble_forecast(
  latitude = 37.30,
  longitude = -79.83,
  forecast_days = 7,
  past_days = 2,
  model = "gfs_seamless",
  variables = c(
    "relativehumidity_2m",
    "precipitation",
    "windspeed_10m",
    "cloudcover",
    "temperature_2m",
    "shortwave_radiation"))
head(df)
```

    ## # A tibble: 6 × 7
    ##   datetime            reference_datetime  model_id  ensemble variable prediction
    ##   <dttm>              <dttm>              <chr>     <chr>    <chr>         <dbl>
    ## 1 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 00       relativ…         65
    ## 2 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 01       relativ…         64
    ## 3 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 02       relativ…         66
    ## 4 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 03       relativ…         65
    ## 5 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 04       relativ…         69
    ## 6 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seam… 05       relativ…         62
    ## # ℹ 1 more variable: unit <chr>

``` r
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction, color = ensemble)) + 
  geom_line() + 
  geom_vline(aes(xintercept = reference_datetime)) + 
  facet_wrap(~variable, scale = "free", ncol = 2)
```

![](README_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

The following converts to GLM format

``` r
path <- tempdir()
df |> 
    RopenMeteo::add_longwave() |>
    RopenMeteo::write_glm_format(path = path)
  head(read.csv(list.files(path = path, full.names = TRUE, pattern = ".csv")[1]))
```

    ##               time AirTemp ShortWave LongWave RelHum WindSpeed Rain
    ## 1 2023-09-20 00:00    14.0        14   290.12     65      1.42    0
    ## 2 2023-09-20 01:00    12.6         0   282.09     69      1.28    0
    ## 3 2023-09-20 02:00    11.8         0   277.67     72      1.13    0
    ## 4 2023-09-20 03:00    11.2         0   274.43     74      1.14    0
    ## 5 2023-09-20 04:00    10.8         0   272.31     76      1.14    0
    ## 6 2023-09-20 05:00    10.6         0   271.26     78      1.14    0

### Converting to Ecological Forecasting Initative convention

The standard used in the NEON Ecological Forecasting Challenge is
slightly different from the standard in this package. It uses the column
`parameter` for ensemble because the Challenge standard allows the
flexibility to use parametric distributions (i.e., normal distribution
`mean` and `sd`) in the same standard as a ensemble (or sample)
forecast. The `family` column defines the distribution (here `family` =
`ensemble`).

The EFI standard also follows CF-conventions so the variable names are
converted to be CF compliant.

The output from `RopenMeteo::convert_to_efi_standard()` is the same as
the output from `neon4cast::stage2()`

Learn more about `neon4cast::stage2()` here:
\[<https://projects.ecoforecast.org/neon4cast-docs/Shared-Forecast-Drivers.html>\]

``` r
df |>
  RopenMeteo::add_longwave() |>
  RopenMeteo::convert_to_efi_standard()
```

    ## # A tibble: 46,872 × 7
    ##    datetime            reference_datetime  model_id    family parameter variable
    ##    <dttm>              <dttm>              <chr>       <chr>  <chr>     <chr>   
    ##  1 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        relativ…
    ##  2 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        precipi…
    ##  3 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        wind_sp…
    ##  4 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        cloudco…
    ##  5 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        air_tem…
    ##  6 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        surface…
    ##  7 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        longwav…
    ##  8 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 01        relativ…
    ##  9 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 01        precipi…
    ## 10 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 01        wind_sp…
    ## # ℹ 46,862 more rows
    ## # ℹ 1 more variable: prediction <dbl>

Note that `neon4cast::stage3()` is similar to

``` r
df |>
  RopenMeteo::add_longwave() |>
  RopenMeteo::convert_to_efi_standard() |> 
  filter(datetime < reference_datetime)
```

    ## # A tibble: 10,416 × 7
    ##    datetime            reference_datetime  model_id    family parameter variable
    ##    <dttm>              <dttm>              <chr>       <chr>  <chr>     <chr>   
    ##  1 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        relativ…
    ##  2 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        precipi…
    ##  3 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        wind_sp…
    ##  4 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        cloudco…
    ##  5 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        air_tem…
    ##  6 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        surface…
    ##  7 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 00        longwav…
    ##  8 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 01        relativ…
    ##  9 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 01        precipi…
    ## 10 2023-09-20 00:00:00 2023-09-22 00:00:00 gfs_seamle… ensem… 01        wind_sp…
    ## # ℹ 10,406 more rows
    ## # ℹ 1 more variable: prediction <dbl>

With the only difference that the number of days is equal to the
`past_days` in the call to `RopenMeteo::get_ensemble_forecast()`. The
max `past_days` from open-meteo is ~60 days.

## Historical Weather

If you need more historical days for model calibration and testing,
historical data are available through open-meteo’s historical weather
API.

\[<https://open-meteo.com/en/docs/historical-weather-api>\]

``` r
df <- RopenMeteo::get_historical_weather(
  latitude = 37.30,
  longitude = -79.83,
  start_date = "2023-01-01",
  end_date = Sys.Date(),
  variables = c("temperature_2m")) 
tail(df |> na.omit())
```

    ## # A tibble: 6 × 5
    ##   datetime            model_id variable       prediction unit 
    ##   <dttm>              <chr>    <chr>               <dbl> <chr>
    ## 1 2023-09-15 18:00:00 ERA5     temperature_2m       21.4 °C   
    ## 2 2023-09-15 19:00:00 ERA5     temperature_2m       22.1 °C   
    ## 3 2023-09-15 20:00:00 ERA5     temperature_2m       23   °C   
    ## 4 2023-09-15 21:00:00 ERA5     temperature_2m       24   °C   
    ## 5 2023-09-15 22:00:00 ERA5     temperature_2m       22.4 °C   
    ## 6 2023-09-15 23:00:00 ERA5     temperature_2m       21.3 °C

Notice the delay of ~7 days.

``` r
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction)) + 
  geom_line(color = "#F8766D") + 
  geom_vline(aes(xintercept = lubridate::with_tz(Sys.time(), tzone = "UTC"))) + 
  facet_wrap(~variable, scale = "free")
```

    ## Warning: Removed 168 rows containing missing values (`geom_line()`).

![](README_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

## Seasonal Forecasts

Weather forecasts for up to 9 months in the future are available from
the NOAA Climate Forecasting System

\[<https://open-meteo.com/en/docs/seasonal-forecast-api>\]

``` r
df <- RopenMeteo::get_seasonal_forecast(
  latitude = 37.30,
  longitude = -79.83,
  forecast_days = 274,
  past_days = 5,
  variables = c("temperature_2m"))
head(df)
```

    ## # A tibble: 6 × 7
    ##   datetime            reference_datetime  model_id ensemble variable  prediction
    ##   <dttm>              <dttm>              <chr>    <chr>    <chr>          <dbl>
    ## 1 2023-09-17 00:00:00 2023-09-22 00:00:00 cfs      01       temperat…        9.5
    ## 2 2023-09-17 00:00:00 2023-09-22 00:00:00 cfs      02       temperat…        9.7
    ## 3 2023-09-17 00:00:00 2023-09-22 00:00:00 cfs      03       temperat…        9.7
    ## 4 2023-09-17 00:00:00 2023-09-22 00:00:00 cfs      04       temperat…        9.8
    ## 5 2023-09-17 06:00:00 2023-09-22 00:00:00 cfs      01       temperat…       14.4
    ## 6 2023-09-17 06:00:00 2023-09-22 00:00:00 cfs      02       temperat…        9.3
    ## # ℹ 1 more variable: unit <chr>

``` r
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction, color = ensemble)) + 
  geom_line() + 
  geom_vline(aes(xintercept = reference_datetime)) +
  facet_wrap(~variable, scale = "free")
```

    ## Warning: Removed 2156 rows containing missing values (`geom_line()`).

![](README_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

## Climate Projections

Climate projections from different models are available through 2050.

\[<https://open-meteo.com/en/docs/climate-api>\]

``` r
df <- RopenMeteo::get_climate_projections(
  latitude = 37.30,
  longitude = -79.83,
  start_date = Sys.Date(),
  end_date = Sys.Date() + lubridate::years(1),
  model = "EC_Earth3P_HR",
  variables = c("temperature_2m_mean"))
head(df)
```

    ## # A tibble: 6 × 5
    ##   datetime   model_id      variable            prediction unit 
    ##   <date>     <chr>         <chr>                    <dbl> <chr>
    ## 1 2023-09-22 EC_Earth3P_HR temperature_2m_mean       13.3 °C   
    ## 2 2023-09-23 EC_Earth3P_HR temperature_2m_mean       14.6 °C   
    ## 3 2023-09-24 EC_Earth3P_HR temperature_2m_mean       18.1 °C   
    ## 4 2023-09-25 EC_Earth3P_HR temperature_2m_mean       15.4 °C   
    ## 5 2023-09-26 EC_Earth3P_HR temperature_2m_mean       16.2 °C   
    ## 6 2023-09-27 EC_Earth3P_HR temperature_2m_mean       14.5 °C

### Multiple climate models

``` r
models <- c("CMCC_CM2_VHR4","FGOALS_f3_H","HiRAM_SIT_HR","MRI_AGCM3_2_S","EC_Earth3P_HR","MPI_ESM1_2_XR","NICAM16_8S")

df <- purrr::map_df(models, function(model){
  RopenMeteo::get_climate_projections(
    latitude = 37.30,
    longitude = -79.83,
    start_date = Sys.Date(),
    end_date = Sys.Date() + lubridate::years(1),
    model = model,
    variables = c("temperature_2m_mean"))
  })
```

``` r
df |> 
    mutate(variable = paste(variable, unit)) |> 
    ggplot(aes(x = datetime, y = prediction, color = model_id)) + 
    geom_line() +
    facet_wrap(~variable, scale = "free")
```

![](README_files/figure-gfm/unnamed-chunk-18-1.png)<!-- -->
