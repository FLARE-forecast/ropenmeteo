# Convert units and names to CF and Ecological Forecasting Initiative standard

Output units:

- air_temperature: K

- relative_humidity: proportion

- surface_downwelling_longwave_flux_in_air: W m-2

- surface_downwelling_shortwave_flux_in_air: W m-2

- precipitation_flux: kg m-2 s-1

- wind_speed: m s-1

- air_pressure: Pa

- cloud_cover: proportion

## Usage

``` r
convert_to_efi_standard(df)
```

## Arguments

- df:

  data frame output by get_ensemble_forecast

## Value

data frame

## Examples

``` r
file <- system.file("extdata", "test-data.csv", package="ropenmeteo")
df <- readr::read_csv(file, show_col_types = FALSE)
df  |>
  add_longwave() |>
  convert_to_efi_standard()
#> # A tibble: 53,568 × 8
#>    datetime            reference_datetime  site_id     model_id family parameter
#>    <dttm>              <dttm>              <chr>       <chr>    <chr>  <chr>    
#>  1 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  2 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  3 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  4 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  5 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  6 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  7 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  8 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 00       
#>  9 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 01       
#> 10 2024-08-19 00:00:00 2024-08-21 00:00:00 37.3_-79.83 gfs_sea… ensem… 01       
#> # ℹ 53,558 more rows
#> # ℹ 2 more variables: variable <chr>, prediction <dbl>
```
