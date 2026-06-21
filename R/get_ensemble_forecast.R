#' Download point-level ensemble weather forecast using open-meteo API
#'
#' @param latitude latitude in decimal degrees north
#' @param longitude longitude in decimal degrees east
#' @param site_id optional site label added to output; defaults to "latitude_longitude"
#' @param forecast_days number of forecast days (max 35)
#' @param past_days number of past days to include (max 92)
#' @param model ensemble model id. Default `"gfs_seamless"`. Common options:
#'   `"gfs_seamless"`, `"icon_seamless_eps"`, `"ecmwf_ifs025"`, `"ecmwf_aifs025"`,
#'   `"gem_global"`, `"bom_access_global"`, `"ukmo_global_20km"`.
#'   Note: `ecmwf_ifs025` does not include shortwave radiation.
#'   See <https://open-meteo.com/en/docs/ensemble-api> for the full list.
#' @param variables character vector of variable names.
#'   See <https://open-meteo.com/en/docs/ensemble-api> for the full list.
#'
#' @returns data frame with the results from the call to the open-meteo API.  The data frame is in a long format and has the following columns: "datetime", "reference_datetime", "site_id", "model_id", "ensemble", "variable", "prediction","unit".
#' @export
#'
#' @examplesIf interactive()
#' get_ensemble_forecast(
#' latitude = 37.30,
#' longitude = -79.83,
#' forecast_days = 7,
#' past_days = 2,
#' model = "gfs_seamless",
#' variables = c("temperature_2m"))
#'
#'
get_ensemble_forecast <- function(latitude,
                                  longitude,
                                  site_id = NULL,
                                  forecast_days,
                                  past_days,
                                  model = "ncep_gefs_seamless",
                                  variables = c("relative_humidity_2m",
                                                "precipitation",
                                                "wind_speed_10m",
                                                "cloud_cover",
                                                "temperature_2m",
                                                "shortwave_radiation")){

  if(forecast_days > 35) stop("forecast_days is longer than avialable (max = 35")
  if(past_days > 3) stop("hist_days is longer than avialable (max = 3)")

  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  if(longitude > 180) longitude <- longitude - 360

  variables_api <- paste(variables,collapse=",")

  url_base <- "https://ensemble-api.open-meteo.com/v1/ensemble"
  url_path <-  glue::glue(
    "?latitude={latitude}&longitude={longitude}&hourly={variables_api}&wind_speed_unit=ms&forecast_days={forecast_days}&past_days={past_days}&models={model}"
  )
  v <- ropenmeteo:::read_url(url_base, url_path)

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





