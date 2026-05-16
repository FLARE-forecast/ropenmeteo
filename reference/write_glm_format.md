# Write ensemble forecast dataframe to General Lake Model formatted csv files

Write ensemble forecast dataframe to General Lake Model formatted csv
files

## Usage

``` r
write_glm_format(df, path)
```

## Arguments

- df:

  data frame output by
  [`get_ensemble_forecast()`](http://flare-forecast.org/ropenmeteo/reference/get_ensemble_forecast.md)

- path:

  directory where csv files will be written

## Value

No return value, called to generate csv files in the GLM required format

## Examples

``` r


file <- system.file("extdata", "test-data.csv", package="ropenmeteo")
df <- readr::read_csv(file, show_col_types = FALSE)
df |>
   add_longwave() |>
   write_glm_format(path = path)
```
