tidal_tools
================

## Goal

This is an R package to read and process tidal data from the Portuguese
National Hydrographic Institute. With it, you can programmatically retrieve tidal tables, estimate tidal height at desired points in time (by
interpolating the height across time) and create simple calendar plots of
tidal events to help you plan field work.

Initially, this package was built as a quick-fix for some work I had to
do, and was more of a personal tool than a public one. Since then, it
has evolved a bit but assumption checks, error handling and error
reporting are not very sophisticated.

If you use this tool, make sure you read the **documentation**, especially how arguments should be passed into
the function. The package has standard R formatted documentation,
meaning you can always use the `?` operator to see the help for a
function.

## Functionality - outdated, use the `?` help in R

### 1\. See port IDs

To retrieve a tidal table, you must specify what port you want by
providing a port ID. You can find the available port IDs through 2
methods:

### *port\_list*

Returns a pre-compiled data.frame with available ports. These ids were
retrieved in February 2020, if you are getting errors with the IDs in
this table, see `get_port_list`.

**usage:**

port\_list()

### *get\_port\_list*

**DO NOT USE UNLESS THE IDS FROM `port_list()` FAIL** Brute forces a
test for all IDs from 0 to 1000 and returns all valid ones. While I
doubt that this would actually put any significant load on the servers,
brute force methods are a little rude so this function is only a back up
in case the pre-compiled IDs fail. It also takes some time to run so
it’s not as convenient.

**usage:**

get\_port\_list()

### 2\. Retrieve a table of tidal events

### *get\_tides*

Returns a data.frame with all tidal, for a time period with a specified
start date and duration. The returned times are always in the local GMT
time for the port (as specified in by the Portuguese National
Hydrographic Institute).

**arguments:**

port\_id - Integer - The id code for the desired port. Use `port_list()`
to see a list of IDs. Defaults to 19, which is Faro-Olhão.

date - Character or POSIXct - The starting date for the wanted tides.
Format should be yyyy-mm-dd or yyyy/mm/dd. Defaults to current date.

day\_range - Integer - The number of days for which to retrieve
information. Defaults to 1 which retrieves only the date for the
provided date

include\_moons - Logical - Should lunar events be kept in the table?
Defaults to FALSE

**usage:**

``` r
table <- get_tides(port_id = 19, date = "2020-03-05", day_range = 2, include_moons = FALSE)

table
```

    ##             date_time height phenomenon
    ## 1 2020-03-05 04:48:00    1.3  Baixa-mar
    ## 2 2020-03-05 11:09:00    2.6  Preia-mar
    ## 3 2020-03-05 17:11:00    1.3  Baixa-mar
    ## 4 2020-03-05 23:39:00    2.9  Preia-mar
    ## 5 2020-03-06 05:53:00    1.1  Baixa-mar
    ## 6 2020-03-06 12:10:00    2.9  Preia-mar
    ## 7 2020-03-06 18:09:00    1.0  Baixa-mar

### 3\. Interpolate tidal heights

### *interpolate\_tides*

> TODO: Add time-zone conversion

Returns a vector with estimated tidal height, at the time points
supplied in date\_times. date\_times A character vector with the format
yyyy-mm-dd hh:mm:ss or POSIXct vector port\_id The id code for the
desired port (use `port_list` to see a list, Faro-Olhão is the default)

**usage**

``` r
sampling_times <- c("2020-03-13 15:15:00", "2020-03-09 16:15:00")
interpolate_tides(date_times = sampling_times, port_id = 19)
```

    ## Interpolating based on tides reported for port ID 19 (Faro - Olhão)

    ## Warning: tz(): Don't know how to compute timezone for object of class POSIXct;
    ## returning "UTC". This warning will become an error in the next major version of
    ## lubridate.

    ## [1] 2.668263 2.881554

### 4\. Plot tides

### *plot\_tides*

Takes a table returned by `get_tides` and turns it into a calendar-style
plot. Ideal for quickly looking at when tidal events occur over a time
period. I recommend adding a `geom_vline` at times of interest to make
interpretation easier and quicker. Used, mostly, to plan field work.

**usage:**

plot(tide\_table)
