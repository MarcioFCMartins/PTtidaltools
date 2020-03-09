#' Get tide table for a port and day
#'
#' This function retrieves the tides for the desired dates and time range
#' @param port_id The id code for the desired port (use valid_ports to see a list)
#' @param date The starting date for the wanted tides. Format should be yyyy-mm-dd or yyyy/mm/dd
#' @param day_range The number of days after date for which to retrieve information
#' @examples
#' Retrieve the information for the Faro - Olhão port, for the 7 days after March 5th of 2020
#' tide_table(port_id = 19, date = "2020-03-05, day_rage = 7)
#' @export

tide_tabe <- function(
    port_id = NULL,
    date = NULL, 
    day_range = NULL) {
    
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
    
    # Retrieve the correct table
    table <- read_html(query_link) 
    table <- html_node(table, ".table-striped")
    table <- html_table(table)
    
    
    names(table) <- c("date_time", "height", "phenomenon")
    
    return(table)
}
