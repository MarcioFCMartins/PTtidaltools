#' Calculate estimated tide heights
#'
#' This function takes a series of time-points and a port ID.
#' It returns the expected tide height at those time-points, for that port
#' based on the method provided by the Portuguese National Hydrographic Institute
#' 
#' @param date_times A character vector with the format yyyy-mm-dd hh:mm:ss OR a POSIXct vector
#' @param port_id The id code for the desired port (use port_list to see a list, Faro-Olhão is the default)
#' 
#' @examples
#' Retrieve the information for the Faro - Olhao port, for the 7 days after March 5th of 2020
#' sampling_times <- c("2020-03-13 15:15:00", "2020-03-09 16:15:00")
#' interpolate_tides(date_times = sampling_times, port_id = 19)
#' @export

interpolate_tides <- function(date_times = NULL, port_id = 19){
    
    message(
        paste0(
            "Interpolating based on tides reported for port ID ",
            port_id,
            " (", port_list()$port_name[port_list()$port_id == port_id],
            ")")
        
    )
    # Convert dates to POSIXct and arranges them in ascending order
    if(is.factor(date_times)){ 
        date_times <- as.character(date_times)
    }
    
    if(is.character(date_times)){
        date_times <- as.POSIXct(date_times,
                                 format = "%Y-%m-%d %H:%M:%S",
                                 tz = "GMT")
    }
    
    # Get list of unique days for which tidal table is required
    days <- as.POSIXct(unique(format(date_times, "%Y-%m-%d")), tz = "GMT")
    
    # Add the days before/after - for when tidal events are across days
    all_days <- integer()
    class(all_days) <- "POSIXct"
    for(i in 1:length(days)){
        current_day <- days[i]
        interval <- c(current_day - 86400,
                      current_day,
                      current_day + 86400)
        
        all_days <- c(all_days, interval)
    }
    
    # Remove duplicate days
    all_days <- unique(all_days)
    
    # Get tidal data 
    tides <- lapply(
        as.character(all_days),
        function(x) get_tides(port_id = port_id, date = x, day_range = 0))
    
    tides <- do.call(rbind, tides)
    
    tides$date_time <- as.POSIXct(tides$date_time)
    
    # Format tide table to use in interpolation:
    # Add a start and end of tidal event (current event = row being processed)
    #   - time reported in tidal table of current event is the end time
    #   - end time of last event is the start of current event

    # Remove first row to prevent issues with leading values
    tides_final <- tides[-1,]
    
    # Adds the current time observations as the end times
    tides_final$end <- as.POSIXct(tides_final$date_time)
    # Adds the leading observations as the start times
    tides_final$start <- tides$date_time[-nrow(tides)]
    
    tides_final$duration <- as.numeric(
        difftime( 
            tides_final$end,
            tides_final$start,
            units = c("hours"))
    )
    
    # BEGIN THE INTERPOLATION:
    # parameters_df will hold the parameters organized in such a way
    # that applying the interpolation formula is trivial
    # the parameters change based on whether the last event was a low or high tide
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # TO-DO: CURRENTLY BREAKS IF TIME INTERVALS ARE NOT CONTINUOUS
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    
    parameters_df <- data.frame()
    
    for(i in 1:length(date_times)){
        sample_time <- date_times[i]
        
        previous_event <- tides_final[tides_final$end < sample_time,]
        previous_event <- previous_event[which.max(previous_event$date_time),]
        
        next_event <- tides_final[tides_final$end >= sample_time,]
        next_event <- next_event[which.min(next_event$date_time),]
        
        if(previous_event$phenomenon[1] == "Baixa-mar"){
            parameters <- data.frame("last_event" = "low",
                                     "H" = next_event$height,
                                     "h" = previous_event$height,
                                     "T1" = next_event$duration,
                                     "t" = as.numeric(
                                         sample_time - previous_event$end,
                                         "hours"))
        } else {
            parameters <- data.frame("last_event" = "high",
                                     "H" = previous_event$height,
                                     "h" = next_event$height,
                                     "T1" = next_event$duration,
                                     "t" = as.numeric(
                                         sample_time - previous_event$end,
                                         "hours"))
        }
        # Append the parameters of one point to parameters for all points
        parameters <- cbind(previous_event, parameters)
        parameters$sample_time <- sample_time
        parameters_df <- rbind(parameters_df, parameters)
    }
    
    
   tidal_heights <- with(
        parameters_df,
        ifelse(last_event == "high",
               (H + h)/2 + (H - h)/2 * cos((pi*t)/T1),
               (h + H)/2 + (h - H)/2 * cos((pi*t)/T1)))
    
    
    return(tidal_heights)
}
