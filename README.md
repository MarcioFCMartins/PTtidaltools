# tidytides
R package to read and process tidal data from the Portuguese National Hydrographic Institute

The main goal of this package is allowing you to pass a vector of date-times and obtain estimated tidal height at those points, for a specified harbor. Also allows you to obtain a simple tidal table (and lunar events) for time period. 

Because this was built as a quick-fix for some work I had to do, and as such more of a personal tool, error handling, reporting and data checks are not very sophisticated. If you use this tool, make sure you read how data should be passed into the arguments.

## Functions

*port_list* 
**usage:** port_list()
Returns a data.frame with ids for the ports available. The id is then used in the other functions. These ids were compiled in February 2020, if you are getting errors with the ids used here, see *get_port_list*.

*get_port_list*
**usage:** 
get_port_list()

Returns a data.frame with an updated list of port ids, by brute-force. It tests all ids from 0 to 1000 and returns all valid ones. This function should not be used unless the ids in *port_list* are not working.

*get_tides*
**usage:** 
tide_table(port_id = 19, date = "2020-03-05", day_range = 7, include_moons = FALSE)

Returns a data.frame with all tidal events for a time period. 
port_id The id code for the desired port. Use valid_ports to see a list of ids. Faro-Olhão is the default
date The starting date for the wanted tides. Format should be yyyy-mm-dd or yyyy/mm/dd
day_range The number of days after date for which to retrieve information
include_moons Should lunar events be kept in the table? TRUE or FALSE

*interpolate_tides*
**usage** 
sampling_times <- c("2020-03-13 15:15:00", "2020-03-09 16:15:00")
interpolate_tides(date_times = sampling_times, port_id = 19)

Returns a vector with estimated tidal height, at the time points supplied in date_times.
date_times A character vector with the format yyyy-mm-dd hh:mm:ss or POSIXct vector
port_id The id code for the desired port (use port_list to see a list, Faro-Olhão is the default)