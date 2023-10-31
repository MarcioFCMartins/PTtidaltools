#' Get tide table for a port and day
#'
#' Returns a data.frame with all tidal, for a time period with a specified start date and duration. The returned times are always in the local GMT time for the port (as specified in by the Portuguese National Hydrographic Institute).
#' 
#' @param port_id  The id code for the desired port. Use `port_list()` to see a list of IDs. Defaults to 19, which is Faro-Olhão.
#' @param start_date  The starting date for the wanted tides. Format should be yyyy-mm-dd or yyyy/mm/dd. Accepts class character, Date and POSIXct. Defaults to current date.
#' @param end_date The end date for the tidal table. Same format as start_date
#' @param day_range OPTIONAL You can skip the end date and just say how many days you are interested in. Defaults to 1 which only provides tides for `start_date`
#' @param include_moons Should lunar events be kept in the table? Defaults to FALSE.
#' @param silent Should messages be suppressed? Defaults to FALSE (display messages).
#' 
#' @examples
#' Retrieve the information for the Faro - Olhao port, for 7 days, starting at March 5th of 2020
#' tides <- get_tides(port_id = 19, date = "2020-03-05", day_range = 7)
#' 
#' @export

get_tides <- function(
        port_id    = 19,
        start_date = Sys.Date(),
        end_date   = NULL,
        day_range  = 1,
        include_moons = FALSE,
        silent = FALSE) {
    
    # Convert start date to `Date` class
    start_date <- eval(start_date)
    start_date <- tryCatch(
        as.Date(start_date),
        error = function(e) {
            message("Could not convert start_date to a Date object.\nTry converting it to a date yourself (see as.Date).")
        })
    stopifnot(
        "Issue with the start_date.\n Please make sure this date exists." = !is.na(start_date)
    )
    
    
    # Calculate day_range needed for query
    if(is.null(end_date)){
        # the HTTP request requires the number of days after the provided date
        day_range <- ifelse(
            day_range <= 0,
            0,
            day_range - 1
        )
    } else {
        end_date <- eval(end_date)
        end_date   <- tryCatch(
            as.Date(end_date),
            error = function(e) {
                message("Could not convert start_date to a Date object.\nTry converting it to a date yourself (see as.Date).")
                stop()
            })   
        stopifnot(
            "Issue with the start_date.\n Please make sure this date exists." = !is.na(end_date)
        )
        
        day_range <- end_date - start_date
    }
    
    # the Hydrographic institute API only reports timezones information
    # when the query starts and ends on different timezones.
    # this is problematic for queries longer than 6 months, so they
    # must be broken into shorter ones to get TZ info
    if(day_range > 150){  # limit range of queries to 150 days
        start <- start_date
        end   <- start_date + day_range
        
        # sequence of dates to query
        query_dates <- seq.Date(
            from = start,
            to   = end,
            by = 150)
        
        # ranges for queries
        query_ranges <- as.numeric(c(query_dates[-1], end) - query_dates)
    } else {
        query_dates <- start_date
        query_ranges <- day_range
    }
    
    
    # Format date for query: yyyymmdd
    query_dates <- gsub("-|/", "",as.character(query_dates))
    
    
    # Build strings that link to the desired query
    query_links <- paste0(
        "https://www.hidrografico.pt/json/mare.port.val.php?po=",
        port_id, "&dd=", query_dates, "&nd=", query_ranges
    )
    
    table_list <- list()
    
    for(query_link in query_links){
        # Scrape the tidal table and time zone
        query_page <- xml2::read_html(query_link)
        
        table <- rvest::html_node(query_page, ".table-striped")
        table <- rvest::html_table(table)
        
        n_cols <- dim(table)[2]
        
        # one time zone
        if(n_cols == 3){
            time_zone <- rvest::html_text(query_page)
            time_zone <- regmatches(
                time_zone, 
                gregexpr("(?<=\\().*?(?=\\))", time_zone, perl=T))[[1]]
            
            
            time_zone <- sub("UTC/GMT", "", time_zone)
            time_zone[time_zone == ""] <- 0
            
            
            
            table[, "time_delta"] <- as.numeric(time_zone)
            
            names(table) <- c("local_date_time", "height", "phenomenon", "time_delta")
        } else {
            # multiple time zones
            time_zones <- rvest::html_text(query_page)
            time_zones <- regmatches(
                time_zones, 
                gregexpr("(?<=\\().*?(?=\\))", time_zones, perl=T))[[1]]
            
            time_zones <- as.data.frame(matrix(time_zones, ncol = 2, byrow = TRUE))
            time_zones[,2] <- sub("UTC/GMT", "", time_zones[, 2])
            time_zones[time_zones == ""] <- 0
            
            names(time_zones) <- c("notes", "time_delta")
            names(table) <- c("local_date_time", "height", "phenomenon", "notes")
            
            table <- merge(table, time_zones, by = "notes")
            
            table$time_delta <- as.numeric(table$time_delta)
        }
        
        # Filter moon events
        if(!include_moons) {
            table <- table[grep("-", table$height, invert = TRUE), ]
        }
        
        # Clean-up heights and convert to numeric
        table$height <- as.numeric(gsub(" m", "", table$height))
        
        # Translate tidal events to English 
        table$phenomenon[table$phenomenon == "Baixa-mar"] <- "low-tide"
        table$phenomenon[table$phenomenon == "Preia-mar"] <- "high-tide"
        
        # Convert local_date_time to POSIXct, with time zone information
        table$local_date_time <- as.POSIXct(
            paste0(table$local_date_time, ":00"),
            format = "%Y-%m-%d %H:%M:%S"
        )
        
        
        table$UTC_date_time <- table$local_date_time - (3600 * table$time_delta)
        
        table <- table[, c("local_date_time", "UTC_date_time", "height", "phenomenon", "time_delta")]
        
        table_list[[query_link]] <- table
    }
    
    final_table <- do.call(
        function(...) rbind(..., make.row.names = FALSE), 
        table_list)[, -5]
    
    if(!silent){
        message(
            paste0(
                "Retrieved tidal table for port ID ",
                port_id,
                " (", port_list()$port_name[port_list()$port_id == port_id],
                ").")
        )
        message("WARNING: due to sea level rise, observed water heights are\n
                approximately +10 cm over shown values.")
    }
    
    return(final_table)
}
