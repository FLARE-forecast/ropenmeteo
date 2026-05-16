#' Download point-level climate projections using open-meteo API
#'
#' Returns daily climate projections from high-resolution CMIP6 models covering
#' 1950–2050. Use [daily_to_hourly()] to downscale to hourly resolution.
#'
#' @param latitude latitude in decimal degrees north
#' @param longitude longitude in decimal degrees east
#' @param site_id optional site label added to output; defaults to "latitude_longitude"
#' @param start_date start of the date range (ISO format "YYYY-MM-DD").
#'   Data available from 1950-01-01.
#' @param end_date end of the date range (ISO format "YYYY-MM-DD").
#'   Projections available through 2050-12-31.
#' @param model climate model id. Default `"EC_Earth3P_HR"`. All seven models:
#'   `"CMCC_CM2_VHR4"`, `"FGOALS_f3_H"`, `"HiRAM_SIT_HR"`, `"MRI_AGCM3_2_S"`,
#'   `"EC_Earth3P_HR"`, `"MPI_ESM1_2_XR"`, `"NICAM16_8S"`.
#'   See <https://open-meteo.com/en/docs/climate-api> for details.
#' @param variables character vector of daily variable names (use `_mean`, `_max`,
#'   `_min`, or `_sum` suffixes as appropriate, e.g. `"temperature_2m_mean"`).
#'   See <https://open-meteo.com/en/docs/climate-api> for the full list.
#'
#' @returns data frame in long format with columns: datetime, site_id, model_id,
#'   variable, prediction, unit. Output is at daily resolution.
#' @export
#' @examplesIf interactive()
#'
#' get_climate_projections(
#' latitude = 37.30,
#' longitude = -79.83,
#' start_date = Sys.Date(),
#' end_date = Sys.Date() + lubridate::years(1),
#' model = "EC_Earth3P_HR",
#' variables = c("temperature_2m_mean"))
#'
get_climate_projections <- function(latitude,
                                    longitude,
                                    site_id = NULL,
                                    start_date,
                                    end_date,
                                    model = "EC_Earth3P_HR",
                                    variables = c("temperature_2m_mean")){

  if(start_date < "1950-01-01") warning("start date must be on or after 1950-01-01")
  #if(end_date > Sys.Date() - lubridate::days(5))

  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  if(longitude > 180) longitude <- longitude - 360

  df <- NULL
  units <- NULL
  for (variable in variables) {

    url_base <- "https://climate-api.open-meteo.com/v1/climate"
    url_path <-  glue::glue(
      "?latitude={latitude}&longitude={longitude}&start_date={start_date}&end_date={end_date}&daily={variable}&wind_speed_unit=ms&models={model}"
    )
    v <- read_url(url_base, url_path)

    units <- dplyr::bind_rows(units, dplyr::tibble(variable = names(v$daily)[2], unit = unlist(v$daily_units[2][1])))
    v1  <- dplyr::as_tibble(v$daily)
    if (variable != variables[1]) {
      v1 <- dplyr::select(v1, -time)
    }
    df <- dplyr::bind_cols(df, v1)
  }

  df <-
    df |> tidyr::pivot_longer(-time, names_to = "variable", values_to = "prediction") |>
    dplyr::rename(datetime = time) |>
    dplyr::mutate(
      model_id = model) |>
    dplyr::left_join(units, by = "variable") |>
    dplyr::mutate(datetime = lubridate::as_date(datetime)) |>
    dplyr::mutate(site_id = ifelse(is.null(site_id), paste0(latitude,"_",longitude), site_id)) |>
    dplyr::select(c("datetime", "site_id", "model_id", "variable", "prediction","unit"))

  return(df)
}
