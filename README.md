# RopenMeteo

R wrappers for APIs on Open-Meteo project.  Currently only works with ensemble forecasts.  Still under development.

Learn more about API at https://open-meteo.com

Example usage:

```
remotes::install_github("FLARE-forecast/RopenMeteo")
path <- tempdir()
RopenMeteo::get_ensemble_forecast(latitude = 37.30, longitude = -79.83, horizon = 2, hist_days = 2) |> 
  RopenMeteo::add_longwave() |> 
  RopenMeteo::write_glm_format(path = path)
  
head(read.csv(list.files(path = path, full.names = TRUE,pattern = ".csv")[1]))
```
