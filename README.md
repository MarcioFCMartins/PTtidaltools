Tidaltools R package
================

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4562490.svg)](https://doi.org/10.5281/zenodo.4562490)

## Goal

This `R` package contains tools to work with the Portuguese National
Hydrographic Institute’s tidal height data - the *tidal tables*.

It has 2 main tasks:

1.  Downloading tidal tables for chosen time periods
2.  Estimate tidal height at given time points

Task 1 is accomplished via their REST API.

Task 2 takes the heights from the tidal tables and interpolates it to
the chosen time points by approximating it as a sin-wave ([reference in
Portuguese](https://www.hidrografico.pt/recursos/tabmares/2021/TabelaMares_Capitulo1_Generalidades_2021.pdf)).

This package started a side-project and was meant to be more of a
personal tool than a public one. Since then it has evolved a lot, but
assumption checks, error handling and error reporting are still not
great. If you use this tool, make sure you read how data should be
passed into the arguments. The package has standard R formatted
documentation, meaning you can always use the `?` operator to see the
help for a function.

## How to use it?

## Installation

Install the `devtools` package. Then you can do
`devtools::install_github("https://github.com/MarcioFCMartins/PTtidaltools")`.

### Select region

To find the ID of the closest port to your reference area use
`port_list()` to see a list of the ports with available tidal tables.
This is a list that I compiled myself. If you think that ID is wrong,
you can use `get_port_list()` to query a new list of IDs (this will take
a while and should be avoided)

### Download tidal tables

To download the tidal tables you can use `get_tides`, which will return
a data.frame with the tidal events for the chosen port and dates. Check
`?get_tides` to see how to use it. Times are returned given both in
local (with daylight savings) and in UTC time.

``` r
# Get tidal tables for Faro-Olhão, starting 5 March 2020 and over 2 days
tidal_table <- get_tides(port_id = 19, start_date = "2020-03-05", day_range = 2)
```

    ## Retrieved tidal table for port ID 19 (Faro - Olhão).

    ## WARNING: due to sea level rise, observed water heights are
    ## approximately +10 cm over shown values.

``` r
tidal_table
```

    ## # A tibble: 7 × 4
    ##   local_date_time     UTC_date_time       height phenomenon
    ##   <dttm>              <dttm>               <dbl> <chr>     
    ## 1 2020-03-05 04:48:00 2020-03-05 04:48:00    1.3 low-tide  
    ## 2 2020-03-05 11:09:00 2020-03-05 11:09:00    2.6 high-tide 
    ## 3 2020-03-05 17:11:00 2020-03-05 17:11:00    1.3 low-tide  
    ## 4 2020-03-05 23:39:00 2020-03-05 23:39:00    2.9 high-tide 
    ## 5 2020-03-06 05:53:00 2020-03-06 05:53:00    1.1 low-tide  
    ## 6 2020-03-06 12:10:00 2020-03-06 12:10:00    2.9 high-tide 
    ## 7 2020-03-06 18:09:00 2020-03-06 18:09:00    1   low-tide

``` r
# Or a tidal table with a specified start and end date
tidal_table <- get_tides(port_id = 19, start_date = "2020-03-05", end_date = "2020-03-07")
```

    ## Retrieved tidal table for port ID 19 (Faro - Olhão).
    ## WARNING: due to sea level rise, observed water heights are
    ## approximately +10 cm over shown values.

### Interpolate tides

You can use `interpolate_tides` to estimate tidal heights at your chosen
port and time points. You also specify if your time points are in
“local” or “UTC” time.

``` r
# Times for which I want to estimate tidal heights
sampling_times <- c("2020-03-13 15:15:00", "2020-03-09 16:15:00")

# Estimate tidal heights for Faro-Olhão harbor. The times at which I want to interpolate are in local time
interpolate_tides(date_times = sampling_times, port_id = 19, timezone = "local")
```

    ## Interpolating all tides assuming LOCAL times.

    ## Retrieved tidal table for port ID 19 (Faro - Olhão).

    ## WARNING: due to sea level rise, observed water heights are
    ## approximately +10 cm over shown values.

    ## [1] 2.952041 2.966681
