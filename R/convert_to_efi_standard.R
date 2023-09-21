#' Convert units and names to CF and EFI standard
#'
#' @param df data frame output by get_ensemble_forecast
#'
#' @return data frame
#' @export
convert_to_efi_standard <- function(df){

  df |>
    dplyr::mutate(variable = ifelse(variable == "temperature", "air_temperature", variable),
           prediction = ifelse(variable == "temperature", prediction + 273.15, prediction)) |>
    dplyr::rename(parameter = ensemble)

}
