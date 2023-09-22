# RopenMeteo

R wrappers for APIs on Open-Meteo project.  

## Install

```
remotes::install_github("FLARE-forecast/RopenMeteo")
```

## Ensemble Weather Forecasts

[https://open-meteo.com/en/docs/ensemble-api]

```
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

```
library(tidyverse)
df |> ggplot(aes(x = datetime, y = prediction, color = ensemble)) + geom_line() + geom_vline(aes(xintercept = reference_datetime)) + facet_wrap(~variable, scale = "free")
```

Options for models and variables are at https://open-meteo.com/en/docs/ensemble-api

Note that `ecmwf_ifs04` does not include solar radiation.  

List of global model ids: 

```
icon_seamless, icon_global, gfs_seamless, gfs025, gfs05, ecmwf_ifs04, gem_global
```

### Use with the General Lake Model

We have included functions that allow the output to be used with the General Lake Model.
Since the models do not include longwave, provide a function to calculate it from the cloud cover and air temperature.

```
path <- tempdir()
df |> 
    RopenMeteo::add_longwave() |>
    RopenMeteo::write_glm_format(path = path)
  head(read.csv(list.files(path = path, full.names = TRUE, pattern = ".csv")[1]))
```

### Converting to the same format in `neon4cast::stage2()`

https://projects.ecoforecast.org/neon4cast-docs/Shared-Forecast-Drivers.html

```
df |>
  RopenMeteo::add_longwave() |>
  RopenMeteo::convert_to_efi_standard()
```

Note that `neon4cast::stage3()` is similar to

```
df |>
  RopenMeteo::add_longwave() |>
  RopenMeteo::convert_to_efi_standard() |> 
  filter(datetime < reference_datetime)
```

With the only difference that the number of days is equal to the `past_days` in the call to `RopenMeteo::get_ensemble_forecast()`.  The max past_days is ~60 days.

## Historical Weather

If you need more historical days for model calibration and testing, historical data are available through open-meteo's historical weather API.

[https://open-meteo.com/en/docs/historical-weather-api] 

```
df <- RopenMeteo::get_historical_weather(
  latitude = 37.30,
  longitude = -79.83,
  start_date = "2023-01-01",
  end_date = Sys.Date(),
  variables = c("temperature_2m"))
head(df)
```

```
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction)) + 
  geom_line() + 
  geom_vline(aes(xintercept = lubridate::with_tz(Sys.time(), tzone = "UTC"))) + 
  facet_wrap(~variable, scale = "free")
```

## Seasonal Forecasts

[https://open-meteo.com/en/docs/seasonal-forecast-api]

```
df <- RopenMeteo::get_seasonal_forecast(
  latitude = 37.30,
  longitude = -79.83,
  forecast_days = 274,
  past_days = 5,
  variables = c("temperature_2m"))
head(df)
```

```
library(tidyverse)
df |> 
  mutate(variable = paste(variable, unit)) |> 
  ggplot(aes(x = datetime, y = prediction, color = ensemble)) + 
  geom_line() + 
  geom_vline(aes(xintercept = reference_datetime)) +
  facet_wrap(~variable, scale = "free")
```

## Climate Projections

[https://open-meteo.com/en/docs/climate-api]

```
df <- get_climate_projections(
  latitude = 37.30,
  longitude = -79.83,
  start_date = Sys.Date(),
  end_date = Sys.Date() + lubridate::years(1),
  model = "EC_Earth3P_HR",
  variables = c("temperature_2m_mean"))
head(df)
```

### Multiple climate models

```
models <- c("CMCC_CM2_VHR4","FGOALS_f3_H","HiRAM_SIT_HR","MRI_AGCM3_2_S","EC_Earth3P_HR","MPI_ESM1_2_XR","NICAM16_8S")

df <- purrr::map_df(models, function(model){
  get_climate_projections(
    latitude = 37.30,
    longitude = -79.83,
    start_date = Sys.Date(),
    end_date = Sys.Date() + lubridate::years(1),
    model = model,
    variables = c("temperature_2m_mean"))
  })
  
```

```
df |> 
    mutate(variable = paste(variable, unit)) |> 
    ggplot(aes(x = datetime, y = prediction, color = model_id)) + 
    geom_line() +
    facet_wrap(~variable, scale = "free")
```


