#' Download point-level ensemble weather forecasting using open-meteo API
#'
#' @param latitude latitude degree north
#' @param longitude long longitude degree east or degree west
#' @param forecast_days Number of days in the future for forecast (starts at current day)
#' @param past_days Number of days in the past to include in the data
#' @param model id of forest model https://open-meteo.com/en/docs/ensemble-api
#' @param variables vector of name of variable(s) https://open-meteo.com/en/docs/ensemble-api
#'
#' @return data frame (in long format)
#' @export
#'
get_ensemble_forecast <- function(latitude,
                                  longitude,
                                  forecast_days,
                                  past_days,
                                  model = "gfs_seamless",
                                  variables = c("relativehumidity_2m",
                                                "precipitation",
                                                "windspeed_10m",
                                                "cloudcover",
                                                "temperature_2m",
                                                "shortwave_radiation")){

  if(forecast_days > 35) stop("forecast_days is longer than avialable (max = 35")
  if(past_days > 92) stop("hist_days is longer than avialable (max = 92)")

  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  if(longitude > 180) longitude <- longitude - 360

  if("shortwave_radiation" %in% variables & model == "ecmwf_ifs04"){
    message("shortwave radiation is not aviailable for ecmwf_ifs04 model")
  }

  df <- NULL
  units <- NULL
  for (variable in variables) {
    v <-
    jsonlite::fromJSON(
        glue::glue(
          "https://ensemble-api.open-meteo.com/v1/ensemble?latitude={latitude}&longitude={longitude}&hourly={variable}&windspeed_unit=ms&forecast_days={forecast_days}&past_days={past_days}&models={model}"
        ))

    units <- dplyr::bind_rows(units, dplyr::tibble(variable = names(v$hourly)[2], unit = unlist(v$hourly_units[2][1])))
    v1  <- dplyr::as_tibble(v$hourly) |>
      dplyr::mutate(time = lubridate::as_datetime(paste0(time,":00")))
    if (variable != variables[1]) {
      v1 <- dplyr::select(v1, -time)
    }
    df <- dplyr::bind_cols(df, v1)
  }

  df <- df |>
    pivot_ensemble_forecast() |>
    dplyr::rename(datetime = time) |>
    dplyr::mutate(
      model_id = model,
      reference_datetime = min(datetime) + lubridate::days(past_days)
    ) |>
    dplyr::left_join(units, by = "variable") |>
    dplyr::select(c("datetime", "reference_datetime", "model_id", "ensemble", "variable", "prediction","unit"))

  return(df)
}





