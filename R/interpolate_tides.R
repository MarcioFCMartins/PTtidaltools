#' Calculate estimated tide heights
#'
#' This function interpolates tides at given time points for any port covered by 
#' the National Hydrographic Institute, or for which a tidal table is provided.
#' 
#' There are 2 main ways to use the function: 
#' 1) Provide a port ID and the function will query the National Hydrographic Institute
#' for the required tidal tables. 
#' 
#' 2) Provide your own tidal table. Great if you want to save a table from
#' `get_tides` and then run the code several times without constantly querying the API, 
#' share it with other people or use the function without internet access.
#' You can also use custom tidal tables, but in that case checking the integrity of
#' the tidal table is mostly up to you.
#' 
#' 
#' Returns the expected tide height at those time-points, for that port
#' based on the method provided by the Portuguese National Hydrographic Institute.
#' 
#' @param date_times A character vector with the format yyyy-mm-dd hh:mm:ss OR a POSIXct vector of date-time points for which tidal height will be estimated.
#' @param port_id The id code for the desired port (use port_list to see a list, Faro-Olhão is the default)
#' @param tidal_table OPTIONAL A table with the tidal events and time at which they occur. If provided, the port_id will be ignored
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
    tides = NULL,
    timezone = "local",
    digits = 2) {
    
    # assert that time_zone is correct
    timezone <- tolower(timezone)
    if(!timezone %in% c("local", "utc")){
        stop("Timezone must be either local or utc. Other timezones are not handled.")
    } else {
        message(paste0("Interpolating all tides assuming ", toupper(timezone), " times."))
    }
    
    # Convert dates to POSIXct
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

    # Add the days before/after the provided time points
    # for when interpolation must be done on events across different days
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
    
    # if tidal table is provided
    if(!is.null(tides)){
        # select which time column to use for interpolation 
        if(timezone == "local"){
            tides$date_time <- as.POSIXct(tides$local_date_time)
        } else {
            tides$date_time <- as.POSIXct(tides$UTC_date_time)
        }
        
        # check for presence of required days in tidal table
        days_in_table <- as.POSIXct(unique(format(tides$date_time, "%Y-%m-%d")))
        
        # stop if days are missing
        if(!all(all_days %in% days_in_table)){
            stop(
                paste0(
                    "The following days are missing in your tidal_table:\n",
                     paste0(all_days[!all_days %in% days_in_table], collapse = "\n")
                    )
            )
        }
    # If a tidal table is NOT provided
    } else {
        # get tidal data from NIH for all days needed for interpolation
        tides <- lapply(
            all_days,
            function(x) get_tides(
                port_id = port_id, 
                date = x, 
                day_range = 0, 
                silent = TRUE)
        )
        
        tides <- do.call(rbind, tides)
        
        # select which time column to use for interpolation 
        if(timezone == "local"){
            tides$date_time <- as.POSIXct(tides$local_date_time)
        } else {
            tides$date_time <- as.POSIXct(tides$UTC_date_time)
        }
    }

    # Almost ready to interpolate!
    # TODO: To handle custom tidal tables better I could use a
    # smarter logic here, instead of just excluding the first row
    # maybe exclude either first or last row based on delta t between events?
    
    # Format tide table:
    #   every row is considered a tidal event (current event = event i)
    # remove first row to prevent issues with leading values
    tides_final <- tides[-1,]
    # Add columns for start and end of current tidal event:
    #   date_time is the end time (or peak) or current event
    tides_final$end <- as.POSIXct(tides_final$date_time)
    #   end time of previous event is the start time of current event
    tides_final$start <- tides$date_time[-nrow(tides)]
    # add column for duration of event
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
       start_date = all_days[1])
    
    return(tidal_heights)
}
