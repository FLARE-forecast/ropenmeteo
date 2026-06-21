#' Download point-level seasonal weather forecast using open-meteo API
#'
#' Returns 6-hourly ensemble forecasts from ECMWF seasonal models. The seamless
#' model uses EC46 for the first 46 days and SEAS5 for up to 7 months ahead.
#'
#' @param latitude latitude in decimal degrees north
#' @param longitude longitude in decimal degrees east
#' @param site_id optional site label added to output; defaults to "latitude_longitude"
#' @param forecast_days number of forecast days. EC46 supports up to 46 days;
#'   SEAS5 and the seamless blend support up to ~214 days (7 months).
#' @param past_days number of past days to include
#' @param model seasonal model id. Default `"ecmwf_seasonal_seamless"`. Other
#'   options: `"ecmwf_seas5"`, `"ecmwf_ec46"`.
#'   See <https://open-meteo.com/en/docs/seasonal-forecast-api> for details.
#' @param variables character vector of variable names.
#'   See <https://open-meteo.com/en/docs/seasonal-forecast-api> for the full list.
#'
#' @returns data frame in long format with columns: datetime, reference_datetime,
#'   site_id, model_id, ensemble, variable, prediction, unit.
#' @export
#' @examplesIf interactive()
#'
#' get_seasonal_forecast(
#'latitude = 37.30,
#'longitude = -79.83,
#'forecast_days = 30,
#'past_days = 5,
#'variables = glm_variables(product = "seasonal_forecast",
#'                          time_step = "6hourly"))
#'
get_seasonal_forecast <- function(latitude,
                                  longitude,
                                  site_id = NULL,
                                  forecast_days,
                                  past_days,
                                  model = "ecmwf_seasonal_seamless",
                                  variables = c("temperature_2m")){

  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  if(longitude > 180) longitude <- longitude - 360

  variables_api <- paste(variables,collapse=",")

  url_base <- "https://seasonal-api.open-meteo.com/v1/seasonal"
  url_path <-  glue::glue(
    "?latitude={latitude}&longitude={longitude}&hourly={variables_api}&wind_speed_unit=ms&forecast_days={forecast_days}&past_days={past_days}&models={model}"
  )
  v <- read_url(url_base, url_path)

  units <- dplyr::tibble(variable = stringr::str_split_i(names(v$hourly),"_member",1), unit = unlist(v$hourly_units)) |> dplyr::distinct() |> dplyr::filter(variable != "time")
  df  <- dplyr::as_tibble(v$hourly) |>
    dplyr::mutate(time = lubridate::as_datetime(paste0(time,":00")))  |>
    pivot_ensemble_forecast() |>
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





