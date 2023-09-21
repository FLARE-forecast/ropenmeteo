# RopenMeteo

R wrappers for APIs on Open-Meteo project.  Currently only works with ensemble forecasts.  Still under development.

Learn more about API at https://open-meteo.com/en/docs/ensemble-api

Example usage:

```
remotes::install_github("FLARE-forecast/RopenMeteo")

df <- RopenMeteo::get_ensemble_forecast(
  latitude = 37.30,
  longitude = -79.83,
  forecast_days = 2,
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

Options for global models and variables are at https://open-meteo.com/en/docs/ensemble-api

Note that `ecmwf_ifs04` does not include solar radiation.  

List of model ids: 

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

If you need more historical days for model calibration and testing, historical data are available through open-meteo's historical weather API (https://open-meteo.com/en/docs/historical-weather-api).  Access to this API is forthcoming.



