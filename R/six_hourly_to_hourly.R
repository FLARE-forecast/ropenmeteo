#' Convert 6 hour seasonal forecast to hourly time-step
#'
#' @param df data frame output by get_seasonal_forecast
#' @param latitude latitude degree north
#' @param longitude long longitude degree east or degree west
#'
#' @return data frame
#' @export
six_hourly_to_hourly <- function(df, latitude, longitude, use_solar_geom = TRUE){

  variables <- unique(df$variable)

  if(!("shortwave_radiation" %in% variables)) warning("missing shortwave")
  if(!("temperature_2m" %in% variables)) warning("missing temperature")
  if(!("precipitation" %in% variables)) warning("missing precipitation")
  if(!("windspeed_10m" %in% variables)) warning("missing windspeed")
  if(!("relativehumidity_2m" %in% variables)) warning("missing relativehumidity")

  df <- df |>
    filter(datetime <= max(df$datetime) - lubridate::hours(18)) |> #remove last day
    dplyr::mutate(family = "ensemble")

  units <- df |> distinct(variable, unit)

  ensemble_maxtime <- df |>
    dplyr::group_by(site_id, family, model_id, ensemble, reference_datetime) |>
    dplyr::summarise(max_time = max(datetime), .groups = "drop")

  ensembles <- unique(df$ensemble)
  datetime <- seq(min(df$datetime), max(df$datetime), by = "1 hour")
  reference_datetime <- unique(df$reference_datetime)
  sites <- unique(df$site_id)
  model_id <- unique(df$model_id)

  full_time <- expand.grid(sites, ensembles, datetime, reference_datetime, model_id) |>
    dplyr::rename(site_id = Var1,
                  ensemble = Var2,
                  datetime = Var3,
                  reference_datetime = Var4,
                  model_id = Var5) |>
    dplyr::mutate(datetime = lubridate::as_datetime(datetime)) |>
    dplyr::arrange(site_id, model_id, ensemble, reference_datetime, datetime) |>
    dplyr::left_join(ensemble_maxtime, by = c("site_id","ensemble", "model_id", "reference_datetime")) |>
    dplyr::filter(datetime <= max_time) |>
    dplyr::select(-c("max_time"))

  df1 <- df |>
    dplyr::select(-unit) |>
    tidyr::pivot_wider(names_from = variable, values_from = prediction) |>
    dplyr::right_join(full_time, by = c("site_id", "model_id", "ensemble", "datetime", "reference_datetime", "family")) |>
    dplyr::arrange(site_id, family, ensemble, datetime) |>
    dplyr::group_by(site_id, family, ensemble)  |>
    tidyr::fill(c("precipitation"), .direction = "up") |>
    tidyr::fill(c("shortwave_radiation"), .direction = "up") |>
    dplyr::mutate(relativehumidity_2m =  imputeTS::na_interpolation(relativehumidity_2m, option = "linear"),
                  windspeed_10m =  imputeTS::na_interpolation(windspeed_10m, option = "linear"),
                  cloudcover =  imputeTS::na_interpolation(cloudcover, option = "linear"),
                  temperature_2m =  imputeTS::na_interpolation(temperature_2m, option = "linear"),
                  precipitation = precipitation/6) |>
    tidyr::pivot_longer(-c("site_id", "model_id", "family", "ensemble", "datetime", "reference_datetime"), names_to = "variable", values_to = "prediction")

  #the first time step is the 6 hour sum from the previous day
  df1 <- df1 |>
    mutate(prediction = ifelse(variable == "precipitation" & datetime == min(df1$datetime),
                               prediction/6,
                               prediction))

  var_order <- names(df1)

  if(use_solar_geom){

    df1 <- df1 |>
      #dplyr::filter(variable == "shortwave_radiation") |>
      dplyr::mutate(shifted_datetime = datetime - lubridate::hours(1)) |>
      dplyr::mutate(hour = lubridate::hour(shifted_datetime),
                    date = lubridate::as_date(shifted_datetime),
                    doy = lubridate::yday(shifted_datetime) + hour/24,
                    lon = ifelse(longitude < 0, 360 + longitude,longitude),
                    rpot = downscale_solar_geom(doy, lon, latitude)) |>  # hourly sw flux calculated using solar geometry
      dplyr::select(-shifted_datetime) |>
      dplyr::group_by(site_id, family, ensemble, reference_datetime, date, variable) |>
      dplyr::mutate(avg.rpot = mean(rpot, na.rm = TRUE),
                    avg.SW = mean(prediction, na.rm = TRUE))|> # daily sw mean from solar geometry
      dplyr::ungroup() |>
      dplyr::mutate(prediction = ifelse(variable %in% c("shortwave_radiation","surface_downwelling_shortwave_flux_in_air") & avg.rpot > 0.0, rpot * (avg.SW/avg.rpot),prediction)) |>
      dplyr::select(any_of(var_order)) |>
      dplyr::left_join(units, by = "variable")
  }

  return(df1)

}
