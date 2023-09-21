#' Write ensemble forecast dataframe to GLM formated csv files
#'
#' @param df data frame output by get_ensemble_forecast
#' @param path directory where csv files will be written
#'
#' @export
#'
write_glm_format <- function(df, path) {

  variables <- unique(df$variable)

  if(!("longwave" %in% variables)) warning("missing longwave")
  if(!("shortwave" %in% variables)) warning("missing shortwave")
  if(!("temperature" %in% variables)) warning("missing temperature")
  if(!("precipitation" %in% variables)) warning("missing precipitation")
  if(!("windspeed" %in% variables)) warning("missing windspeed")
  if(!("relativehumidity" %in% variables)) warning("missing relativehumidity")

  ensemble_list <- df |> dplyr::distinct(model_id, ensemble)

  purrr::walk(1:nrow(ensemble_list),
              function(i, ensemble_list, df) {
                df |>
                  #dplyr::select(-unit) |>
                  dplyr::filter(model_id == ensemble_list$model_id[i],
                                    ensemble == ensemble_list$ensemble[i]) |>
                  tidyr::pivot_wider(names_from = variable, values_from = prediction) |>
                  dplyr::rename(
                    LongWave = longwave,
                    ShortWave = shortwave,
                    AirTemp = temperature,
                    Rain = precipitation,
                    WindSpeed = windspeed,
                    RelHum = relativehumidity,
                    time = datetime
                  ) |>
                  dplyr::select(-dplyr::any_of(c("ensemble","model_id","cloudcover", "reference_datetime"))) |>
                  dplyr::select(time, AirTemp, ShortWave, LongWave, RelHum, WindSpeed, Rain) |>
                  dplyr::mutate(time = strftime(time, format = "%Y-%m-%d %H:%M", tz = "UTC")) |>
                  write.csv(
                    file = file.path(
                      normalizePath(path),
                      paste0(
                        "met_",
                        ensemble_list$model_id[i],
                        "_",
                        ensemble_list$ensemble[i],
                        ".csv"
                      )
                    ),
                    quote = FALSE,
                    row.names = FALSE
                  )

              }, ensemble_list, df)
}
