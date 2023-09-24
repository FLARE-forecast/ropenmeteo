#' Download point-level ensemble weather forecasting using open-meteo API
#'
#' @param latitude latitude degree north
#' @param longitude long longitude degree east or degree west
#' @param site_id = name of site location (optional, default = NULL)
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
                                  site_id = NULL,
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

  variables_api <- paste(variables,collapse=",")

  v <- jsonlite::fromJSON(
      glue::glue(
        "https://ensemble-api.open-meteo.com/v1/ensemble?latitude={latitude}&longitude={longitude}&hourly={variables_api}&windspeed_unit=ms&forecast_days={forecast_days}&past_days={past_days}&models={model}"
      ))

  units <- dplyr::tibble(variable = stringr::str_split_i(names(v$hourly),"_member",1), unit = unlist(v$hourly_units)) |> dplyr::distinct() |> dplyr::filter(variable != "time")
  df  <- dplyr::as_tibble(v$hourly) |>
    dplyr::mutate(time = lubridate::as_datetime(paste0(time,":00")))  |>
    RopenMeteo:::pivot_ensemble_forecast() |>
    dplyr::rename(datetime = time) |>
    dplyr::mutate(
      model_id = model,
      reference_datetime = min(datetime) + lubridate::days(past_days)
    ) |>
    dplyr::left_join(units, by = "variable") |>
    dplyr::mutate(site_id = ifelse(is.null(site_id), paste0(latitude,"_",longitude), site_id)) |>
    dplyr::select(c("datetime", "reference_datetime", "site_id", "model_id", "ensemble", "variable", "prediction","unit"))


  return(df)
}





