tidytides
================

## Goal

This is an R package to read and process tidal data from the Portuguese
National Hydrographic Institute.

With it, you can retrieve tidal tables programmatically, estimate tidal
height at desired points in time and create simple calendar plots of
tidal events to help you plan field work.

Initially, this package was built as a quick-fix for some work I had to
do, and was more of a personal tool than a public one. As such,
assumption checks, error handling and error reporting are not very
sophisticated (although this might be more attributed to my ignorance on
these subjects).

If you use this tool, make sure you read how data should be passed into
the arguments. The package has standard R formatted documentation,
meaning you can always use the `?` operator to see the help for a
function.

## Functionality

### 1\. See port IDs

To retrieve a tidal table, you must specify what port you want. This
package includes 2 ways to do that:

#### *port\_list*

Returns a pre-compiled data.frame with available ports. These ids were
retrieved in February 2020, if you are getting errors with the IDs in
this table, see *get\_port\_list*.

**usage:**

port\_list()

#### *get\_port\_list*

**DO NOT USE UNLESS THE IDS FROM port\_list() FAIL** Brute forces a test
for all IDs from 0 to 1000 and returns all valid ones. While I doubt
that this would actually put any significant load on the servers, brute
force methods are a little rude so this function is only a back up in
case the pre-compiled IDs fail. It also takes some time to run so it’s
not as convenient.

**usage:**

get\_port\_list()

### 2\. Retrieve a tidal table

#### *get\_tides*

Returns a data.frame with all tidal events for a time period.

port\_id - Integer - The id code for the desired port. Use `port_list()`
to see a list of IDs. Defaults to Faro-Olhão. date - Character or
POSIXct - The starting date for the wanted tides. Format should be
yyyy-mm-dd or yyyy/mm/dd. Defaults to current date day\_range - Integer
- The number of days after date for which to retrieve information
include\_moons - Logical - Should lunar events be kept in the table?
Defaults to FALSE

**usage:**

``` r
table <- get_tides(port_id = 19, date = "2020-03-05", day_range = 7, include_moons = FALSE)

table
```

    ##              date_time height phenomenon
    ## 1  2020-03-05 04:48:00    1.3  Baixa-mar
    ## 2  2020-03-05 11:09:00    2.6  Preia-mar
    ## 3  2020-03-05 17:11:00    1.3  Baixa-mar
    ## 4  2020-03-05 23:39:00    2.9  Preia-mar
    ## 5  2020-03-06 05:53:00    1.1  Baixa-mar
    ## 6  2020-03-06 12:10:00    2.9  Preia-mar
    ## 7  2020-03-06 18:09:00    1.0  Baixa-mar
    ## 8  2020-03-07 00:34:00    3.1  Preia-mar
    ## 9  2020-03-07 06:44:00    0.8  Baixa-mar
    ## 10 2020-03-07 13:01:00    3.1  Preia-mar
    ## 11 2020-03-07 18:58:00    0.8  Baixa-mar
    ## 12 2020-03-08 01:23:00    3.4  Preia-mar
    ## 13 2020-03-08 07:29:00    0.5  Baixa-mar
    ## 14 2020-03-08 13:48:00    3.3  Preia-mar
    ## 15 2020-03-08 19:43:00    0.5  Baixa-mar
    ## 16 2020-03-09 02:09:00    3.6  Preia-mar
    ## 17 2020-03-09 08:12:00    0.3  Baixa-mar
    ## 18 2020-03-09 14:33:00    3.5  Preia-mar
    ## 20 2020-03-09 20:25:00    0.3  Baixa-mar
    ## 21 2020-03-10 02:54:00    3.7  Preia-mar
    ## 22 2020-03-10 08:53:00    0.2  Baixa-mar
    ## 23 2020-03-10 15:17:00    3.6  Preia-mar
    ## 24 2020-03-10 21:06:00    0.2  Baixa-mar
    ## 25 2020-03-11 03:38:00    3.8  Preia-mar
    ## 26 2020-03-11 09:33:00    0.2  Baixa-mar
    ## 27 2020-03-11 15:59:00    3.6  Preia-mar
    ## 28 2020-03-11 21:47:00    0.2  Baixa-mar

### 

#### *interpolate\_tides*

**usage** sampling\_times \<- c(“2020-03-13 15:15:00”, “2020-03-09
16:15:00”) interpolate\_tides(date\_times = sampling\_times, port\_id =
19)

Returns a vector with estimated tidal height, at the time points
supplied in date\_times. date\_times A character vector with the format
yyyy-mm-dd hh:mm:ss or POSIXct vector port\_id The id code for the
desired port (use port\_list to see a list, Faro-Olhão is the default)

#### *plot\_tides*

**usage:** plot(tide\_table)

Takes a table returned by **get\_tides** and turns it into a
calendar-style plot. Ideal for quickly looking at when tidal events
occur over a time period. I recomment adding a geom\_vline at times of
interest to make interpretation easier and quicker. Used, mostly, to
plan field work.
