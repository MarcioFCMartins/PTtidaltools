teste <- c(
    seq(
        as.POSIXct("2020-03-10 15:00:00"), 
        as.POSIXct("2020-03-13 15:00:00"), 
        by = "min"),
    seq(
        as.POSIXct("2020-02-10 15:00:00"), 
        as.POSIXct("2020-02-12 15:00:00"),
        by = "min"
    )
)

teste <- seq(
    as.POSIXct("2020-03-10 15:00:00"), 
    as.POSIXct("2020-03-15 15:00:00"), 
    by = "min")


teste2 <- data.frame(
    "time" = teste,
    "height" = interpolate_tides(teste)
)

mares <- get_tides(date = "2020-03-10", day_range = 6) %>%
    mutate(date_time = as.POSIXct(date_time))

ggplot() +
    geom_line(
        data = teste2,
        aes(x = time, y = height)
    ) +
    geom_point(
        data = mares,
        aes(x = date_time, y = height)
    ) +
    theme_minimal()
