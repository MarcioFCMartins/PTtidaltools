#' Get tide table for a port and day
#'
#' This function retrieves the tides for the desired dates and time range.
#' By default, data for the Faro - Olhão port, for the current day, is retrieved.
#' @param port_id The id code for the desired port (use valid_ports to see a list)
#' @param date The starting date for the wanted tides. Format should be yyyy-mm-dd or yyyy/mm/dd
#' @param day_range The number of days after date for which to retrieve information
#' @param include_moons Should lunar events be kept in the table? TRUE or FALSE
#' @examples
#' Retrieve the information for the Faro - Olhão port, for the 7 days after March 5th of 2020
#' tide_table(port_id = 19, date = "2020-03-05, day_rage = 7)
#' @export

tide_table <- function(
    port_id = 19,
    date = NULL, 
    day_range = NULL,
    include_moons = FALSE) {
    
    # Format date for query
    date <- ifelse(
        is.null(date),
        Sys.Date(),
        gsub("-|/", "",as.character(date)))
    
    # Format range for query
    day_range <- ifelse(is.null(day_range), 0, day_range - 1)
    
    query_link <- paste0(
        "https://www.hidrografico.pt/json/mare.port.val.php?po=",
        port_id, "&dd=", date, "&nd=", day_range
    )
    
    # Retrieve the events table
    table <- xml2::read_html(query_link) 
    table <- rvest::html_node(table, ".table-striped")
    table <- rvest::html_table(table)
    
    names(table) <- c("date_time", "height", "phenomenon")
    
    # Remove moon events
    if(!moons) table <- table[-grep("-", table$height), ]
    
    # Clean-up heights and convert to numeric
    table$height <- as.numeric(gsub(" m", "", table$height))
    
    
    return(table)
}
