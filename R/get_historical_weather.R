#' Download point-level historical weather (ERA5) using open-meteo API
#'
#' @param latitude latitude in decimal degrees north
#' @param longitude longitude in decimal degrees east
#' @param site_id optional site label added to output; defaults to "latitude_longitude"
#' @param start_date earliest date requested (ISO format "YYYY-MM-DD").
#'   ERA5 is available from 1940-01-01 to present.
#' @param end_date latest date requested (ISO format "YYYY-MM-DD"). Note that
#'   ERA5 has a processing delay of approximately 5 days.
#' @param variables character vector of variable names.
#'   See <https://open-meteo.com/en/docs/historical-weather-api> for the full list.
#'
#' @returns data frame in long format with columns: datetime, site_id, model_id,
#'   variable, prediction, unit. model_id is always "ERA5".
#' @export
#' @examplesIf interactive()
#' get_historical_weather(
#' latitude = 37.30,
#' longitude = -79.83,
#' start_date = "2023-01-01",
#' end_date = Sys.Date(),
#' variables = c("temperature_2m"))
#'
get_historical_weather <- function(latitude,
                                  longitude,
                                  site_id = NULL,
                                  start_date,
                                  end_date,
                                  variables = c("relative_humidity_2m",
                                                "precipitation",
                                                "wind_speed_10m",
                                                "cloud_cover",
                                                "temperature_2m",
                                                "shortwave_radiation")){

  if(start_date < "1940-01-01") warning("start date must be on or after 1940-01-01")
  #if(end_date > Sys.Date() - lubridate::days(5))


  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  if(longitude > 180) longitude <- longitude - 360

  df <- NULL
  units <- NULL
  url_base <- "https://archive-api.open-meteo.com/v1/archive"
  for (variable in variables) {

    url_path <-  glue::glue(
      "?latitude={latitude}&longitude={longitude}&start_date={start_date}&end_date={end_date}&hourly={variable}&wind_speed_unit=ms"
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

  df <-
    df |> tidyr::pivot_longer(-time, names_to = "variable", values_to = "prediction") |>
    dplyr::rename(datetime = time) |>
    dplyr::mutate(
      model_id = "ERA5") |>
    dplyr::left_join(units, by = "variable") |>
    dplyr::mutate(site_id = ifelse(is.null(site_id), paste0(latitude,"_",longitude), site_id)) |>
    dplyr::select(c("datetime", "site_id", "model_id", "variable", "prediction","unit"))


  return(df)
}





