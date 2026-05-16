file <- system.file("extdata", "test-data.csv", package = "ropenmeteo")
df_base <- readr::read_csv(file, show_col_types = FALSE)

test_that("add_longwave adds longwave_radiation variable with valid values", {
  df <- df_base |> add_longwave()

  expect_s3_class(df, "data.frame")
  expect_true("longwave_radiation" %in% df$variable)

  lw <- df$prediction[df$variable == "longwave_radiation"]
  expect_true(all(!is.na(lw)))
  expect_true(all(lw > 0))
})

test_that("write_glm_format writes correctly named files with expected columns", {
  df <- df_base |> add_longwave()
  path <- tempdir()

  write_glm_format(df, path = path)

  files <- list.files(path, pattern = "met_gfs_seamless_.*\\.csv",
                      full.names = FALSE)
  expect_gt(length(files), 0)

  met <- read.csv(file.path(path, files[1]))
  expect_named(met, c("time", "AirTemp", "ShortWave", "LongWave",
                      "RelHum", "WindSpeed", "Rain"))
  expect_gt(nrow(met), 0)
})

test_that("convert_to_efi_standard converts variable names and units correctly", {
  df <- df_base |> add_longwave() |> convert_to_efi_standard()

  expect_s3_class(df, "data.frame")

  # variable names renamed
  expect_true("air_temperature" %in% df$variable)
  expect_false("temperature_2m" %in% df$variable)
  expect_true("relative_humidity" %in% df$variable)
  expect_false("relative_humidity_2m" %in% df$variable)
  expect_true("precipitation_flux" %in% df$variable)
  expect_true("wind_speed" %in% df$variable)
  expect_true("surface_downwelling_longwave_flux_in_air" %in% df$variable)
  expect_true("surface_downwelling_shortwave_flux_in_air" %in% df$variable)

  # temperature converted to Kelvin
  temp <- df$prediction[df$variable == "air_temperature"]
  expect_true(all(temp > 200, na.rm = TRUE))

  # relative humidity as proportion 0-1
  rh <- df$prediction[df$variable == "relative_humidity"]
  expect_true(all(rh >= 0 & rh <= 1, na.rm = TRUE))

  # EFI structural requirements
  expect_true("parameter" %in% names(df))
  expect_false("ensemble" %in% names(df))
  expect_true(all(df$family == "ensemble"))
})

test_that("glm_variables returns correct variable sets", {
  hourly <- glm_variables("ensemble_forecast", "hourly")
  expect_true("temperature_2m" %in% hourly)
  expect_true("surface_pressure" %in% hourly)
  expect_true("shortwave_radiation" %in% hourly)
  expect_true("wind_speed_10m" %in% hourly)

  # forecast and historical use the same hourly set
  expect_identical(glm_variables("forecast", "hourly"), hourly)
  expect_identical(glm_variables("historical", "hourly"), hourly)

  seasonal <- glm_variables("seasonal_forecast", "6hourly")
  expect_true("temperature_2m" %in% seasonal)
  expect_false("surface_pressure" %in% seasonal)  # not available seasonally

  climate <- glm_variables("climate_projection", "daily")
  expect_true("temperature_2m_mean" %in% climate)
  expect_true("precipitation_sum" %in% climate)
  expect_false("temperature_2m" %in% climate)  # daily uses _mean/_sum suffixes

  expect_error(glm_variables("ensemble_forecast", "daily"))
})
