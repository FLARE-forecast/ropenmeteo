# RopenMeteo

R wrappers for APIs on Open-Meteo project.  Currently only works with ensemble forecasts.  Still under development.

Learn more about API at https://open-meteo.com/en/docs/ensemble-api

Example usage:

```
remotes::install_github("FLARE-forecast/RopenMeteo")
path <- tempdir()
RopenMeteo::get_ensemble_forecast(
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
    "shortwave_radiation")) |>
    RopenMeteo::add_longwave() |>
    RopenMeteo::write_glm_format(path = path)
  
  head(read.csv(list.files(path = path, full.names = TRUE, pattern = ".csv")[1]))
```

Options for global models and variables are at https://open-meteo.com/en/docs/ensemble-api

Note that `ecmwf_ifs04` does not include solar radiation.  

List of model ids: 

```
icon_seamless, icon_global, gfs_seamless, gfs025, gfs05, ecmwf_ifs04, gem_global
```


