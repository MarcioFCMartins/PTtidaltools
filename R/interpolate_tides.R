#' Calculate estimated tide heights
#'
#' This function takes a date time vector and calculates expected tide height at those times
#' based on the method provided by the Portuguese National Hydrographic Institute
#' 
#' @param date_times A character or date vector with the format yyyy-mm-dd hh:mm:ss
#' @param port_id The id code for the desired port (use valid_ports to see a list, Faro-Olhão is the default)
#' 
#' @examples
#' Retrieve the information for the Faro - Olhao port, for the 7 days after March 5th of 2020
#' sampling_times <- c("2020-03-13 15:15:00", "2020-03-09 16:15:00")
#' interpolate_tides(date_times = sampling_times, port_id = 19)
#' @export

interpolate_tides <- function(date_times = NULL, port_id = 19){
    # Convert dates to POSIXct and arrange in ascending order
    # This function uses 'lubridate' to ease the date handling,
    # but I kept it to a minimum
    if(is.factor(date_times)) date_times <- as.character(date_times)
    date_times <- as.POSIXct(date_times, tz = "GMT")[order(date_times)]
    
    # Get list of unique days required
    days <- unique(format(date_times, "%Y-%m-%d"))
    
    # Create a new vector with all supplied dates, and all days before / after
    all_days <- integer()
    class(all_days) <- "POSIXct"
    for(i in 1:length(days)){
        current_day <- as.POSIXct(days[i], tz = "GMT")
        interval <- c(current_day - lubridate::period(1, "day"),
                      current_day,
                      current_day + lubridate::period(1, "day"))
        
        all_days <- c(all_days, interval)
    }
    
    # Ensure we don't keep duplicate dates
    all_days <- unique(all_days)
    
    # Get tidal data for all required days
    tides <- lapply(
        as.character(all_days),
        function(x) get_tides(port_id = port_id, date = x, day_range = 0))
    
    tides <- do.call(rbind, tides)
    
    tides$date_time <- as.POSIXct(tides$date_time)
    # Format tide table to use in interpolation by adding start and end times
    tides$end <- as.POSIXct(tides$date_time)
    
    # Remove first row to prevent issues with lagging the times (NAs)
    tides_final <- tides[-1,]
    
    # This lagged observation approach only works because we already added 
    # extra days around the desired ones, for safety. 
    tides_final$start <- tides$date_time[-nrow(tides)]
    
    
    tides_final$duration <- as.numeric(
        lubridate::as.duration(
            lubridate::as.interval(tides_final$start, tides_final$end)
        ),
        "hours"
    )
    
    # parameters_df will hold the parameters organized in such a way
    # that applying the interpolation formula is trivial
    # the parameters depend on wether the last event was a low or high tide
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # BREAKS FOR NON-CONTINUOUS INTERVALS
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    
    parameters_df <- data.frame()
    
    for(i in 1:length(date_times)){
        sample_time <- date_times[i]
        
        
        previous_event <- tides_final[tides_final$end < date_times[i],]
        previous_event <- previous_event[which.max(previous_event$date_time),]
        
        next_event <- tides_final[tides_final$end >= date_times[i],]
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
        parameters_df <- rbind(parameters_df, parameters)
    }
    
    
    tide_heights <- with(
        parameters_df,
        ifelse(last_event == "high",
               (H + h)/2 + (H - h)/2 * cos((pi*t)/T1),
               (h + H)/2 + (h - H)/2 * cos((pi*t)/T1)))
    
    return(tide_heights)
}
