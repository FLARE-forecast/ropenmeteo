# Add longwave to ensemble forecast dataframe using Idso and Jackson (1969). Requires cloud cover and temperature variables in input data frame.

Add longwave to ensemble forecast dataframe using Idso and Jackson
(1969). Requires cloud cover and temperature variables in input data
frame.

## Usage

``` r
add_longwave(df)
```

## Arguments

- df:

  data frame output from one of the functions that gets a data frame
  from the API (e.g., `get_ensemble_forecast`). The data frame must has
  `cloud_cover` and `temperature_2m` as variables

## Value

data frame with the same columns as the input `df` but with
`longwave_radiation` added as a variable

## Examples

``` r

file <- system.file("extdata", "test-data.csv", package="ropenmeteo")
df <- readr::read_csv(file, show_col_types = FALSE)
df  |>
add_longwave()
#> # A tibble: 53,568 × 8
#>    datetime            reference_datetime  site_id    model_id ensemble variable
#>    <dttm>              <dttm>              <chr>      <chr>    <chr>    <chr>   
#>  1 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       relativ…
#>  2 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       precipi…
#>  3 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       wind_sp…
#>  4 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       cloud_c…
#>  5 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       tempera…
#>  6 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       shortwa…
#>  7 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       surface…
#>  8 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 00       longwav…
#>  9 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 01       relativ…
#> 10 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.… gfs_sea… 01       precipi…
#> # ℹ 53,558 more rows
#> # ℹ 2 more variables: prediction <dbl>, unit <chr>
```
