
# --- Offline input-validation tests (no network needed) ---

test_that("get_forecast rejects forecast_days > 16", {
  expect_error(
    get_forecast(37.30, -79.83, forecast_days = 17, past_days = 2),
    "max = 16"
  )
})

test_that("get_forecast rejects past_days > 92", {
  expect_error(
    get_forecast(37.30, -79.83, forecast_days = 7, past_days = 93),
    "max = 92"
  )
})

test_that("get_ensemble_forecast rejects forecast_days > 35", {
  expect_error(
    get_ensemble_forecast(37.30, -79.83, forecast_days = 36, past_days = 2),
    "max = 35"
  )
})

# --- Online API tests ---

test_that("get_ensemble_forecast returns expected structure", {
  skip_if_offline()
  skip_on_cran()

  df <- get_ensemble_forecast(
    latitude = 37.30,
    longitude = -79.83,
    forecast_days = 7,
    past_days = 2,
    model = "gfs_seamless",
    variables = c("temperature_2m", "wind_speed_10m"))

  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0)
  expect_named(df, c("datetime", "reference_datetime", "site_id",
                     "model_id", "ensemble", "variable", "prediction", "unit"))
  expect_true(all(c("temperature_2m", "wind_speed_10m") %in% df$variable))
  expect_equal(unique(df$model_id), "gfs_seamless")

  # wind_speed_unit=ms regression: API silently returned km/h with old "windspeed_unit" param
  wind_unit <- df$unit[df$variable == "wind_speed_10m"][1]
  expect_false(grepl("km", wind_unit))
})

test_that("get_ensemble_forecast works with ecmwf_ifs025", {
  skip_if_offline()
  skip_on_cran()

  df <- get_ensemble_forecast(
    latitude = 37.30,
    longitude = -79.83,
    forecast_days = 7,
    past_days = 2,
    model = "ecmwf_ifs025",
    variables = c("temperature_2m"))

  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0)
  expect_named(df, c("datetime", "reference_datetime", "site_id",
                     "model_id", "ensemble", "variable", "prediction", "unit"))
})

test_that("get_historical_weather returns expected structure", {
  skip_if_offline()
  skip_on_cran()

  df <- get_historical_weather(
    latitude = 37.30,
    longitude = -79.83,
    start_date = "2023-01-01",
    end_date = Sys.Date() - lubridate::days(1),
    variables = c("temperature_2m"))

  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0)
  expect_named(df, c("datetime", "site_id", "model_id", "variable", "prediction", "unit"))
  expect_equal(unique(df$model_id), "ERA5")
  expect_true("temperature_2m" %in% df$variable)
})

test_that("get_seasonal_forecast returns expected structure", {
  skip_if_offline()
  skip_on_cran()

  df <- get_seasonal_forecast(
    latitude = 37.30,
    longitude = -79.83,
    forecast_days = 30,
    past_days = 5,
    variables = c("temperature_2m"))

  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0)
  expect_named(df, c("datetime", "reference_datetime", "site_id",
                     "model_id", "ensemble", "variable", "prediction", "unit"))
  expect_true("temperature_2m" %in% df$variable)
  expect_equal(unique(df$model_id), "ecmwf_seasonal_seamless")
})

test_that("get_climate_projections returns expected structure", {
  skip_if_offline()
  skip_on_cran()

  df <- get_climate_projections(
    latitude = 37.30,
    longitude = -79.83,
    start_date = Sys.Date(),
    end_date = Sys.Date() + lubridate::years(1),
    model = "EC_Earth3P_HR",
    variables = c("temperature_2m_mean"))

  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0)
  expect_named(df, c("datetime", "site_id", "model_id", "variable", "prediction", "unit"))
  expect_equal(unique(df$model_id), "EC_Earth3P_HR")
  expect_true("temperature_2m_mean" %in% df$variable)
})

test_that("get_forecast works with generic model", {
  skip_if_offline()
  skip_on_cran()

  df <- get_forecast(
    latitude = 37.30,
    longitude = -79.83,
    forecast_days = 7,
    past_days = 2,
    model = "generic",
    variables = c("temperature_2m", "wind_speed_10m"))

  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0)
  expect_named(df, c("datetime", "reference_datetime", "site_id",
                     "model_id", "variable", "prediction", "unit"))

  # wind_speed_unit=ms regression
  wind_unit <- df$unit[df$variable == "wind_speed_10m"][1]
  expect_false(grepl("km", wind_unit))
})

test_that("get_forecast works with dwd model", {
  skip_if_offline()
  skip_on_cran()

  df <- get_forecast(
    latitude = 37.30,
    longitude = -79.83,
    forecast_days = 7,
    past_days = 2,
    model = "dwd",
    variables = c("temperature_2m"))

  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0)
  expect_named(df, c("datetime", "reference_datetime", "site_id",
                     "model_id", "variable", "prediction", "unit"))
})
