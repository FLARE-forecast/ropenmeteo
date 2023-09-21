#' Write ensemble forecast dataframe to GLM formated csv files
#'
#' @param df
#' @param path
#'
#' @return
#' @export
#'
#' @examples
write_glm_format <- function(df, path) {

  ensemble_list <- df |> dplyr::distinct(model_id, ensemble)

  purrr::walk(1:nrow(ensemble_list),
              function(i, ensemble_list, df) {
                df |> dplyr::filter(model_id == ensemble_list$model_id[i],
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
