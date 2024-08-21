test_that("write_glm_format works", {
  skip_if_offline()

  df <- get_ensemble_forecast(
    latitude = 37.30,
    longitude = -79.83,
    forecast_days = 7,
    past_days = 2,
    model = "gfs_seamless",
    variables = RopenMeteo::glm_variables(product = "ensemble_forecast",
                                          time_step = "hourly"))

  df <- df |>
    add_longwave()

  expect_s3_class(df, "data.frame")

  path <- tempdir()
  df |>
    write_glm_format(path = path)

  file_names <- read.csv(list.files(path = path, full.names = TRUE, pattern = ".csv")[1])

  expect_s3_class(file_names, "data.frame")

  efi <- df |>
  convert_to_efi_standard()

  expect_s3_class(efi, "data.frame")
})

