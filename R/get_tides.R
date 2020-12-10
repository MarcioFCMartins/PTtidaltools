#' Get tide table for a port and day
#'
#' Returns a data.frame with all tidal, for a time period with a specified start date and duration. The returned times are always in the local GMT time for the port (as specified in by the Portuguese National Hydrographic Institute).
#' 
#' @param port_id  The id code for the desired port. Use `port_list()` to see a list of IDs. Defaults to 19, which is Faro-Olhão.
#' @param date  The starting date for the wanted tides. Format should be yyyy-mm-dd or yyyy/mm/dd. Defaults to current date
#' @param day_range The number of days for which to retrieve information. Defaults to 1 which retrieves only the date for the provided date
#' @param include_moons Should lunar events be kept in the table? Defaults to FALSE
#' 
#' @examples
#' Retrieve the information for the Faro - Olhao port, for 7 days, starting at March 5th of 2020
#' tides <- get_tides(port_id = 19, date = "2020-03-05", day_range = 6)
#' 
#' @export

get_tides <- function(
    port_id = 19,
    date = Sys.Date(), 
    day_range = 1,
    include_moons = FALSE) {
    
    
    # Format date for query - convert to character and remove separators 
    # to have yyyymmdd format as required for HTTP request
    date <- gsub("-|/", "",as.character(date))
    
    # the HTTP request requires the number of days after the provided date
    # subtract 1 from provided range
    day_range <- ifelse(
        day_range < 0,
        0,
        day_range - 1
    )
    
    # Build string that links to the desired query
    query_link <- paste0(
        "https://www.hidrografico.pt/json/mare.port.val.php?po=",
        port_id, "&dd=", date, "&nd=", day_range
    )
    
    # Scrape the tidal table and time zones
    query_page <- xml2::read_html(query_link)
    
    table <- rvest::html_node(query_page, ".table-striped")
    table <- rvest::html_table(table)
    
    time_zone <- rvest::html_text(query_page)
    time_zone <- regmatches(
        time_zone, 
        gregexpr("(?<=\\().*?(?=\\))", time_zone, perl=T))[[1]]
    time_zone <- sub(
        "UTC/",
        "",
        time_zone
    )
    
    names(table) <- c("date_time", "height", "phenomenon")
    
    # Filter moon events
    if(!include_moons) {
        table <- table[grep("-", table$height, invert = TRUE), ]
    }
    
    # Clean-up heights and convert to numeric
    table$height <- as.numeric(gsub(" m", "", table$height))
    
    # Translate tidal events to English 
    table$phenomenon[table$phenomenon == "Baixa-mar"] <- "low-tide"
    table$phenomenon[table$phenomenon == "Preia-mar"] <- "high-tide"
    
    # Convert date_time to POSIXct, with time zone information
    table$date_time <- as.POSIXct(
        paste0(table$date_time, ":00"),
        tz = time_zone,
        format = "%Y-%m-%d %H:%M:%S"
    )

    message(
        paste0(
            "Retrieved tidal table for port ID ",
            port_id,
            " (", port_list()$port_name[port_list()$port_id == port_id],
            "). \nTime-zone used is ",
            time_zone,
            ".")
    ) 
        
    return(table)
}
