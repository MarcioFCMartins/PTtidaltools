#' Internal function: Optimize tide queries
#'
#' This function takes a vector of dates and returns a list of optimized
#' start - end date pairs that cover the entire time window for which
#' tidal tables are required. 
#' 
#' Only use-case is to make the `interpolate` run faster for long time windows
#' 
#' @param all_days A date vector for all days for which a tidal table is required
#' @noRd

optimize_queries <- function(all_days){
    # Start by calculating the interval between consecutive days
    time_diffs <- all_days[-1] - all_days[-length(all_days)]
    
    # If breaks between days are always 2 days or less, send a single query
    if(all(time_diffs <= 2)){
        queries <- list(c(min(all_days), max(all_days)))
    } else {
        query_ids <- cumsum(c(time_diffs, 0) > 2) + 1
        queries <- list()
        
        for(id in unique(query_ids)){
            query_dates <- all_days[query_ids == id]
            
            query_start_date <- min(query_dates)
            query_end_date   <- max(query_dates)
            
            queries[[id]] <- c(query_start_date, query_end_date)
        }
    }
    
    return(queries)
    
}
