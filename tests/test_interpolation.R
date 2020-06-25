# broken
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

a <- interpolate_tides(teste)
teste2 <- data.frame(
    "time" = teste,
    "height" = a$est_height
)

mares <- get_tides(date = "2020-03-10", day_range = 3) %>%
    mutate(date_time = as.POSIXct(date_time))

mares2 <- get_tides(date = "2020-02-10", day_range = 2) %>%
    mutate(date_time = as.POSIXct(date_time))

ggplotly(
ggplot() +
    geom_line(
        data = a,
        aes(x = sample_time, y = est_height)
    ) +
    geom_line(
        data = teste2,
        aes(x = time, y = height),
        color = "red"
    ) +
    geom_point(
        data = mares,
        aes(x = date_time, y = height)
    ) +
    geom_point(
        data = mares2,
        aes(x = date_time, y = height)
    ) +
    theme_minimal())

# works
teste <-
    seq(
        as.POSIXct("2020-03-10 15:00:00"), 
        as.POSIXct("2020-03-13 15:00:00"), 
        by = "min")


teste2 <- data.frame(
    "time" = teste,
    "height" = interpolate_tides(teste)
)

mares <- get_tides(date = "2020-03-10", day_range = 4) %>%
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
