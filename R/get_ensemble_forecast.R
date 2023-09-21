get_ensemble_forecast <- function(latitude, longitude, horizon, hist_days, model = "gfs_seamless", variables = c("relativehumidity_2m",
                                                                                                                  "precipitation",
                                                                                                                  "windspeed_10m",
                                                                                                                  "cloudcover",
                                                                                                                  "temperature_2m",
                                                                                                                  "shortwave_radiation")){

  latitude <- round(latitude, 2)
  longitude <- round(longitude, 2)

  df <- NULL
  for (variable in variables) {
    v <-
      readr::read_csv(
        glue::glue(
          "https://ensemble-api.open-meteo.com/v1/ensemble?latitude={latitude}&longitude={longitude}&hourly={variable}&forecast_days={horizon}&past_days={hist_days}&models={model}&format=csv"
        ),
        skip = 2,
        show_col_types = FALSE
      )
    if (variable != variables[1]) {
      v <- dplyr::select(v,-time)
    }
    df <- dplyr::bind_cols(df, v)
  }

  df <-
    df |> tidyr::pivot_longer(-time, names_to = "variable_ens", values_to = "prediction") |>
    dplyr::mutate(
      variable = stringr::str_split(
        variable_ens,
        pattern = "_",
        n = 2,
        simplify = TRUE
      )[, 1],
      ensemble = stringr::str_split(
        variable_ens,
        pattern = "_",
        n = 2,
        simplify = TRUE
      )[, 2],
      ensemble = ifelse(
        stringr::str_detect(ensemble, pattern = "member", negate = TRUE),
        "member00 unit",
        ensemble
      ),
      ensemble = stringr::str_sub(
        stringr::str_split(ensemble, "member", n = 2, simplify = TRUE)[, 2],
        1,
        2
      ),
      variable = stringr::str_split(variable, " ", simplify = TRUE)[, 1]
    ) |>
    dplyr::select(-variable_ens) |>
    dplyr::rename(datetime = time) |>
    dplyr::mutate(
      model_id = model,
      reference_datetime = min(datetime) + lubridate::days(hist_days)
    )

  return(df)
}





