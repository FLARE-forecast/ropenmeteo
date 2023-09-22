#' Convert units and names to CF and EFI standard
#'
#' @param df data frame output by get_ensemble_forecast
#'
#' @return data frame
#' @export
convert_to_efi_standard <- function(df){

  df <- df |>
    dplyr::mutate(variable = ifelse(variable == "temperature_2m", "air_temperature", variable),
           prediction = ifelse(variable == "air_temperature", prediction + 273.15, prediction),
           variable = ifelse(variable == "relativehumidity_2m", "relative_humidity", variable),
           prediction = ifelse(variable == "relative_humidity", prediction/100, prediction),
           variable = ifelse(variable == "longwave", "surface_downwelling_longwave_flux_in_air", variable),
           variable = ifelse(variable == "shortwave_radiation", "surface_downwelling_shortwave_flux_in_air", variable),
           variable = ifelse(variable == "precipitation", "precipitation_flux", variable),
           prediction = ifelse(variable == "precipitation_flux", prediction/(60 * 60), prediction),
           variable = ifelse(variable == "windspeed_10m", "wind_speed", variable),
           variable = ifelse(variable == "surface_pressure", "air_pressure", variable),
           prediction = ifelse(variable == "air_pressure", prediction * 100, prediction),
           variable = ifelse(variable == "cloud_area_fraction", "cloudcover", variable),
           prediction = ifelse(variable == "cloud_area_fraction", prediction/100, prediction)) |>
    dplyr::select(-unit) |>
    dplyr::select(dplyr::any_of(c("model_id", "datetime", "parameter", "ensemble", "reference_datetime", "variable", "prediction")))

  if("ensemble" %in% names(df)) df <- df |> dplyr::rename(parameter = ensemble)

  return(df)
}
