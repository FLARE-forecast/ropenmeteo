#' Add longwave to ensemble forecast dataframe using Idso and Jackson (1969)
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
add_longwave <- function(df) {
  df |>
    tidyr::pivot_wider(names_from = variable, values_from = prediction) |>
    dplyr::mutate(cloudcover = ifelse(cloudcover < 0, 0, cloudcover)) |>
    dplyr::mutate(
      eps_star = (1.0 + 0.275 * cloudcover / 100) * (1.0 - 0.261 * exp(-0.000777 * temperature ^ 2.0)),
      longwave = round((1 - 0.03) * eps_star * 5.67E-8 * (273.15 +
                                                            temperature) ^ 4.0, 2)
    ) |>
    dplyr::select(-eps_star) |>
    tidyr::pivot_longer(-dplyr::any_of(c(
      "datetime", "ensemble", "model_id", "reference_datetime","unit"
    )),
    names_to = "variable",
    values_to = "prediction")

}
