#' Download point-level weather forecast using open-meteo API
#'
#' Returns the best-match single forecast (not ensemble) for a location. Use
#' [get_ensemble_forecast()] for probabilistic ensemble output.
#'
#' @param latitude latitude in decimal degrees north
#' @param longitude longitude in decimal degrees east
#' @param site_id optional site label added to output; defaults to "latitude_longitude"
#' @param forecast_days number of forecast days (max 16)
#' @param past_days number of past days to include (max 92)
#' @param model weather model id. Default `"generic"` selects the best available
#'   model for each location. Other options: `"gfs"`, `"ecmwf"`, `"meteofrance"`,
#'   `"dwd"`, `"gem"`, `"jma"`, `"metno"`, `"kma"`, `"bom"`, `"ukmo"`.
#'   See <https://open-meteo.com/en/docs> for details.
#' @param variables character vector of variable names.
#'   See <https://open-meteo.com/en/docs> for the full list.
#'
#' @return data frame in long format with columns: datetime, reference_datetime,
#'   site_id, model_id, variable, prediction, unit
#' @export
#'
#' @examplesIf interactive()
#'get_forecast(latitude = 37.30,
#'             longitude = -79.83,
#'             forecast_days = 7,
#'             past_days = 2,
#'            model = "generic",
#'             variables = c("temperature_2m"))
get_forecast <- function(latitude,
                         longitude,
                         site_id = NULL,
                         forecast_days,
                         past_days,
                         model = "generic",
                         variables = c("temperature_2m")){

  if(forecast_days > 16) stop("forecast_days is longer than available (max = 16)")
  if(past_days > 92) stop("past_days is longer than available (max = 92)")

  api <- switch(model,
                "generic"     = "/v1/forecast",
                "metno"       = "/v1/metno",
                "dwd"         = "/v1/forecast",
                "gfs"         = "/v1/gfs",
                "meteofrance" = "/v1/meteofrance",
                "ecmwf"       = "/v1/ecmwf",
                "jma"         = "/v1/jma",
                "gem"         = "/v1/gem",
                "kma"         = "/v1/forecast",
                "bom"         = "/v1/forecast",
                "ukmo"        = "/v1/forecast")

  models_param <- switch(model,
                         "dwd"  = "&models=icon_seamless",
                         "kma"  = "&models=kma_seamless",
                         "bom"  = "&models=bom_access_global",
                         "ukmo" = "&models=ukmo_seamless",
                         "")

  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  if(longitude > 180) longitude <- longitude - 360

  df <- NULL
  units <- NULL
  for (variable in variables) {

    url_base <- "https://api.open-meteo.com"
    url_path <-  glue::glue(
      "{api}?latitude={latitude}&longitude={longitude}&hourly={variable}&wind_speed_unit=ms&forecast_days={forecast_days}&past_days={past_days}{models_param}"
    )
    v <- read_url(url_base, url_path)

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
    dplyr::mutate( model_id = model,
                   reference_datetime = min(datetime) + lubridate::days(past_days)) |>
    dplyr::left_join(units, by = "variable") |>
    dplyr::mutate(site_id = ifelse(is.null(site_id), paste0(latitude,"_",longitude), site_id)) |>
    dplyr::select(c("datetime", "reference_datetime", "site_id", "model_id", "variable", "prediction","unit"))

  return(df)
}





