#' Download point-level ensemble weather forecasting using open-meteo API
#'
#' @param latitude latitude degree north
#' @param longitude long longitude degree east or degree west
#' @param forecast_days Number of days in the future for forecast (starts at current day)
#' @param past_days Number of days in the past to include in the data
#' @param variables vector of name of variable(s) https://open-meteo.com/en/docs/ensemble-api
#'
#' @return data frame (in long format)
#' @export
#'
get_forecast <- function(latitude,
                         longitude,
                         forecast_days,
                         past_days,
                         variables = c("temperature_2m")){

  if(forecast_days > 35) stop("forecast_days is longer than avialable (max = 35")
  if(past_days > 92) stop("hist_days is longer than avialable (max = 92)")

  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  if(longitude > 180) longitude <- longitude - 360

  df <- NULL
  units <- NULL
  for (variable in variables) {
    v <-
      jsonlite::fromJSON(
        glue::glue(
          "https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&hourly={variable}&windspeed_unit=ms&forecast_days={forecast_days}&past_days={past_days}"
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
    tidyr::pivot_longer(-time, names_to = "variable", values_to = "prediction") |>
    dplyr::rename(datetime = time) |>
    dplyr::mutate( model_id = "open_meteo_best",
                   reference_datetime = min(datetime) + lubridate::days(past_days)) |>
    dplyr::left_join(units, by = "variable") |>
    dplyr::select(c("datetime", "model_id", "variable", "prediction","unit"))

  return(df)
}





