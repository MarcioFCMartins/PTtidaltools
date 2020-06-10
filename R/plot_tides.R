#' Plot a calendar of the tidal events for each day
#'
#' If you pass it a tides table (from get_tides), a ggplot of the high and low tides will be created. I suggest adding vertical lines (geom_vline) to make visualization easier
#' 
#' @param tides The tides table, obtained from get_tides
#' 
#' @examples
#' plot_tides(tides_table)
#' 
#' 
#' @export

plot_tides <- function(tides){
    ggplot(data = tides) +
    geom_point(
        aes(x = as.numeric(strftime(date_time, "%H")), y = height, color = phenomenon)) +
    facet_grid(
        cols = vars(factor(wday(date_time, locale = 'en_GB.UTF-8', week_start = 1))),
        rows = vars(isoweek(date_time)),
        labeller = labeller(.cols = c("1" = "Monday",
                                      "2" = "Tuesday",
                                      "3" = "Wednesday",
                                      "4" = "Thursday",
                                      "5" = "Friday",
                                      "6" = "Saturday",
                                      "7" = "Sunday"))) +
    geom_text(
        aes(x = -Inf, y = +Inf, label = day(date_time),
            vjust = 1, hjust = 0)
    ) +
    labs(
        x = "Time",
        y = "Tide height (m)"
    ) +
    theme_bw()
}
