#' Calculate estimated tide heights
#'
#' This function interpolates tides at given time points for any port covered by 
#' the National Hydrographic Institute.
#' 
#' You must specify the port ID and provide the list of date-time points for which
#' tidal height should be estimated.
#' 
#' It returns the expected tide height at those time-points, for that port
#' based on the method provided by the Portuguese National Hydrographic Institute.
#' 
#' @param port_id The id code for the desired port (use port_list to see a list, Faro-Olhão is the default)
#' @param date_times A character vector with the format yyyy-mm-dd hh:mm:ss OR a POSIXct vector of date-time points for which tidal height will be estimated.
#' @param timezone The timezone used for `date_times`. Must be one of "local" (which includes time changes due to daylight savings) or "UTC".
#' 
#' @examples
#' Retrieve the information for the Faro - Olhao port, for the 7 days after March 5th of 2020.
#' sampling_times <- c("2020-03-13 15:15:00", "2020-03-09 16:15:00")
#' interpolate_tides(port_id = 19, date_times = sampling_times, timezone = "local")
#' @export

interpolate_tides <- function(
    date_times = NULL, 
    port_id = 19,
    timezone = "local"){
    
    # assert that time_zone is correct
    timezone <- tolower(timezone)
    if(!timezone %in% c("local", "utc")){
        stop("Timezone must be either local or utc. Other timezones are not handled.")
    } else(
        message(paste0("Interpolating all tides assuming ", toupper(timezone), " times."))
    )
    
    # Convert dates to POSIXct and arranges them in ascending order
    if(is.factor(date_times)){ 
        date_times <- as.character(date_times)
    }
    
    if(is.character(date_times)){
        date_times <- as.POSIXct(date_times,
                                 format = "%Y-%m-%d %H:%M:%S")
    }
    
    # Get list of unique days for which tidal table is required
    days <- as.POSIXct(
        unique(format(date_times, "%Y-%m-%d"))
    )
    
    
    # Add the days before/after the provided time points - for when tidal events are across days
    all_days <- NULL
    for(i in 1:length(days)){
        current_day <- days[i]
        interval <- c(current_day - 86400,
                      current_day,
                      current_day + 86400)
        
        if(is.null(all_days)){
            all_days <- interval
        } else {
            all_days <- c(all_days, interval)
        }
    }
    
    # remove duplicate days
    all_days <- unique(all_days)
    
    # get tidal data for all days needed for interpolation
    tides <- lapply(
        all_days,
        function(x) get_tides(
            port_id = port_id, 
            date = x, 
            day_range = 0, 
            silent = TRUE)
    )
    
    tides <- do.call(rbind, tides)
    
    # interpolation uses the column called date_time
    # select which timezone to use for such column 
    if(timezone == "local"){
        tides$date_time <- as.POSIXct(tides$local_date_time)
    } else {
        tides$date_time <- as.POSIXct(tides$UTC_date_time)
    }

    # Format tide table to use in interpolation:
    #   every row is considered a tidal event (current event)
    # remove first row to prevent issues with leading values
    tides_final <- tides[-1,]
    # I add columns for start and end of current tidal event current:
    #   date_time in original table is the end time (or peak) or current event
    #   end time of last event is the start time of current event
    tides_final$end <- as.POSIXct(tides_final$date_time)
    tides_final$start <- tides$date_time[-nrow(tides)]
    # add column for durantion of event
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
    
   # Interpolate
   tidal_heights <- with(
        parameters_df,
        ifelse(last_event == "high",
               (H + h)/2 + (H - h)/2 * cos((pi*t)/T1),
               (h + H)/2 + (h - H)/2 * cos((pi*t)/T1)))
   
   # Call get_tides a single time just to display the information
   # about the query to the user
   get_tides(
       port_id = port_id,
       date = all_days[1])
    
    return(tidal_heights)
}
