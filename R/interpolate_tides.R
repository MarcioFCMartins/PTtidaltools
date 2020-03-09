#' Takes a vector of date times and returns the expected tide for a port
#'
#' This function retrieves the tides for the desired dates and time range
#' @param port_id The id code for the desired port (use valid_ports to see a list)
#' @param date The starting date for the wanted tides. Format should be yyyy-mm-dd or yyyy/mm/dd
#' @param day_range The number of days after date for which to retrieve information
#' @examples
#' Retrieve the information for the Faro - Olhão port, for the 7 days after March 5th of 2020
#' tide_table(port_id = 19, date = "2020-03-05, day_rage = 7)
#' @export

interpolate_tides <- function(date_time = NULL, port_id = NULL){
    # Get the full list of tides for days included 
    #days <- unique days in vector
    #tides <- get the tide_table for all days and append
    
    # Interpolate using functions documented in the tide tables
    message("This function has not been implemented yet")
}