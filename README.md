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
    site_id = optional column to identify site location
    model_id = id of model that generated the forecast
    ensemble = ensemble member number (only for ensemble weather and seasonal forecasts)
    variable = forecasted variable
    prediction = forecasted value
    unit = units of the variable

## Install

``` r
remotes::install_github("FLARE-forecast/RopenMeteo")
```

    ## 
    ## ── R CMD build ─────────────────────────────────────────────────────────────────
    ##      checking for file ‘/private/var/folders/ms/kf9vk0w17p18pvs8k_23t5y80000gq/T/RtmpCDlkv6/remotes155811a455fe2/FLARE-forecast-RopenMeteo-4a22c6a/DESCRIPTION’ ...  ✔  checking for file ‘/private/var/folders/ms/kf9vk0w17p18pvs8k_23t5y80000gq/T/RtmpCDlkv6/remotes155811a455fe2/FLARE-forecast-RopenMeteo-4a22c6a/DESCRIPTION’
    ##   ─  preparing ‘RopenMeteo’:
    ##      checking DESCRIPTION meta-information ...  ✔  checking DESCRIPTION meta-information
    ##   ─  checking for LF line-endings in source and make files and shell scripts
    ##   ─  checking for empty or unneeded directories
    ##   ─  building ‘RopenMeteo_0.1.tar.gz’
    ##      
    ## 

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
    ## 1 2023-09-21 00:00:00 2023-09-23 00:00:00 generic  temperature…       18   °C   
    ## 2 2023-09-21 01:00:00 2023-09-23 00:00:00 generic  temperature…       17   °C   
    ## 3 2023-09-21 02:00:00 2023-09-23 00:00:00 generic  temperature…       16.4 °C   
    ## 4 2023-09-21 03:00:00 2023-09-23 00:00:00 generic  temperature…       17   °C   
    ## 5 2023-09-21 04:00:00 2023-09-23 00:00:00 generic  temperature…       17.1 °C   
    ## 6 2023-09-21 05:00:00 2023-09-23 00:00:00 generic  temperature…       17.6 °C

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
    ## 1 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 00       tempera…       17  
    ## 2 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 01       tempera…       17.4
    ## 3 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 02       tempera…       17.6
    ## 4 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 03       tempera…       17.3
    ## 5 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 04       tempera…       17.4
    ## 6 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 05       tempera…       17.2
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
  variables = RopenMeteo::glm_variables(product = "ensemble_forecast", 
                                        time_step = "hourly"))
head(df)
```

    ## # A tibble: 6 × 7
    ##   datetime            reference_datetime  model_id  ensemble variable prediction
    ##   <dttm>              <dttm>              <chr>     <chr>    <chr>         <dbl>
    ## 1 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 00       relativ…         68
    ## 2 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 01       relativ…         69
    ## 3 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 02       relativ…         65
    ## 4 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 03       relativ…         66
    ## 5 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 04       relativ…         69
    ## 6 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seam… 05       relativ…         67
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
    ## 1 2023-09-21 00:00    17.0         5   388.28     68      1.02    0
    ## 2 2023-09-21 01:00    15.7         0   379.65     73      0.72    0
    ## 3 2023-09-21 02:00    14.8         0   374.34     77      0.54    0
    ## 4 2023-09-21 03:00    14.1         0   370.65     80      0.51    0
    ## 5 2023-09-21 04:00    13.5         0   366.19     83      0.50    0
    ## 6 2023-09-21 05:00    13.0         0   362.54     85      0.50    0

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
    ##  1 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        relativ…
    ##  2 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        precipi…
    ##  3 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        wind_sp…
    ##  4 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        cloudco…
    ##  5 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        air_tem…
    ##  6 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        surface…
    ##  7 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        longwav…
    ##  8 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 01        relativ…
    ##  9 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 01        precipi…
    ## 10 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 01        wind_sp…
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
    ##  1 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        relativ…
    ##  2 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        precipi…
    ##  3 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        wind_sp…
    ##  4 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        cloudco…
    ##  5 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        air_tem…
    ##  6 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        surface…
    ##  7 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 00        longwav…
    ##  8 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 01        relativ…
    ##  9 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 01        precipi…
    ## 10 2023-09-21 00:00:00 2023-09-23 00:00:00 gfs_seamle… ensem… 01        wind_sp…
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
    ## 1 2023-09-16 18:00:00 ERA5     temperature_2m       24.2 °C   
    ## 2 2023-09-16 19:00:00 ERA5     temperature_2m       24.6 °C   
    ## 3 2023-09-16 20:00:00 ERA5     temperature_2m       25.4 °C   
    ## 4 2023-09-16 21:00:00 ERA5     temperature_2m       25.6 °C   
    ## 5 2023-09-16 22:00:00 ERA5     temperature_2m       23.8 °C   
    ## 6 2023-09-16 23:00:00 ERA5     temperature_2m       23.1 °C

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
    ## 1 2023-09-18 00:00:00 2023-09-23 00:00:00 cfs      01       temperat…       15.3
    ## 2 2023-09-18 00:00:00 2023-09-23 00:00:00 cfs      02       temperat…       15.8
    ## 3 2023-09-18 00:00:00 2023-09-23 00:00:00 cfs      03       temperat…       15.3
    ## 4 2023-09-18 00:00:00 2023-09-23 00:00:00 cfs      04       temperat…       15.2
    ## 5 2023-09-18 06:00:00 2023-09-23 00:00:00 cfs      01       temperat…       13  
    ## 6 2023-09-18 06:00:00 2023-09-23 00:00:00 cfs      02       temperat…       12.4
    ## # ℹ 1 more variable: unit <chr>

``` r
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction, color = ensemble)) + 
  geom_line() + 
  geom_vline(aes(xintercept = reference_datetime)) +
  facet_wrap(~variable, scale = "free")
```

    ## Warning: Removed 2172 rows containing missing values (`geom_line()`).

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
    ## 1 2023-09-23 EC_Earth3P_HR temperature_2m_mean       14.6 °C   
    ## 2 2023-09-24 EC_Earth3P_HR temperature_2m_mean       18.1 °C   
    ## 3 2023-09-25 EC_Earth3P_HR temperature_2m_mean       15.4 °C   
    ## 4 2023-09-26 EC_Earth3P_HR temperature_2m_mean       16.2 °C   
    ## 5 2023-09-27 EC_Earth3P_HR temperature_2m_mean       14.5 °C   
    ## 6 2023-09-28 EC_Earth3P_HR temperature_2m_mean       12.4 °C

``` r
df |> 
    mutate(variable = paste(variable, unit)) |> 
    ggplot(aes(x = datetime, y = prediction)) + 
    geom_line(color = "#F8766D") + 
    facet_wrap(~variable, scale = "free")
```

![](README_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->

## Downloading multiple sites or models

### Multiple models

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

![](README_files/figure-gfm/unnamed-chunk-19-1.png)<!-- -->

### multiple sites

The download of multiple sites uses the optional `site_id` to add column
that denotes the different sites.

``` r
sites <- tibble::tibble(site_id = c("fcre", "sunp"),
                        latitude = c(37.30, 43.39),
                        longitude = c(-79.83, -72.05))

df <- purrr::map_df(1:nrow(sites), function(i, sites){
  RopenMeteo::get_climate_projections(
    latitude = sites$latitude[i],
    longitude = sites$longitude[i],
    site_id = sites$site_id[i],
    start_date = Sys.Date(),
    end_date = Sys.Date() + lubridate::years(1),
    model = "MPI_ESM1_2_XR",
    variables = c("temperature_2m_mean"))
  },
  sites)
head(df)
```

    ## # A tibble: 6 × 6
    ##   datetime   site_id model_id      variable            prediction unit 
    ##   <date>     <chr>   <chr>         <chr>                    <dbl> <chr>
    ## 1 2023-09-23 fcre    MPI_ESM1_2_XR temperature_2m_mean       12.2 °C   
    ## 2 2023-09-24 fcre    MPI_ESM1_2_XR temperature_2m_mean       12   °C   
    ## 3 2023-09-25 fcre    MPI_ESM1_2_XR temperature_2m_mean       14.7 °C   
    ## 4 2023-09-26 fcre    MPI_ESM1_2_XR temperature_2m_mean       17.8 °C   
    ## 5 2023-09-27 fcre    MPI_ESM1_2_XR temperature_2m_mean       19.3 °C   
    ## 6 2023-09-28 fcre    MPI_ESM1_2_XR temperature_2m_mean       21.6 °C

``` r
df |> 
    mutate(variable = paste(variable, unit)) |> 
    ggplot(aes(x = datetime, y = prediction, color = site_id)) + 
    geom_line() +
    facet_wrap(~variable, scale = "free")
```

![](README_files/figure-gfm/unnamed-chunk-21-1.png)<!-- -->
