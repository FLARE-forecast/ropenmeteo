#' Add longwave to ensemble forecast dataframe using Idso and Jackson (1969).  Requires cloud cover and temperature variables in input data frame.
#'
#' @param df data frame output by `get_ensemble_forecast()`
#'
#' @return data frame (in long format)
#' @export
#' @examples
#' get_ensemble_forecast(
#'     latitude = 37.30,
#'     longitude = -79.83,
#'     forecast_days = 7,
#'     past_days = 2,
#'     model = "gfs_seamless",
#'     variables = c("cloud_cover", "temperature_2m")) |>
#' add_longwave()
#'
add_longwave <- function(df) {

  unit_table <- df |>
    dplyr::distinct(variable, unit) |>
    dplyr::bind_rows(dplyr::tibble(variable = "longwave_radiation", unit = "(W/m2)"))

  df |>
    dplyr::select(-unit) |>
    tidyr::pivot_wider(names_from = variable, values_from = prediction) |>
    dplyr::mutate(cloud_cover = ifelse(cloud_cover < 0, 0, cloud_cover)) |>
    dplyr::mutate(
      eps_star = (1.0 + 0.275 * cloud_cover / 100) * (1.0 - 0.261 * exp(-0.000777 * temperature_2m ^ 2.0)),
      longwave_radiation = round((1 - 0.03) * eps_star * 5.67E-8 * (273.15 +
                                                            temperature_2m) ^ 4.0, 2)
    ) |>
    dplyr::select(-eps_star) |>
    tidyr::pivot_longer(-dplyr::any_of(c(
      "datetime", "ensemble", "model_id", "reference_datetime", "site_id", "parameter", "family")),
    names_to = "variable",
    values_to = "prediction") |>
    dplyr::left_join(unit_table, by = "variable") |>
    dplyr::select(dplyr::any_of(c("datetime", "reference_datetime", "site_id", "model_id", "parameter", "family", "ensemble", "variable", "prediction","unit")))

}
