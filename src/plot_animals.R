library(plotly)

g <- list(
  scope = 'europe',
  showframe = F,
  showland = T,
  landcolor = toRGB("grey90")
)

g1 <- c(
  g,
  resolution = 50,
  showcoastlines = T,
  countrycolor = toRGB("white"),
  coastlinecolor = toRGB("white"),
  projection = list(type = 'Mercator'),
  list(lonaxis = list(range = c(-15, -5))),
  list(lataxis = list(range = c(0, 12))),
  list(domain = list(x = c(0, 1), y = c(0, 1)))
)

g2 <- c(
  g,
  showcountries = F,
  bgcolor = toRGB("white", alpha = 0),
  list(domain = list(x = c(0, .6), y = c(0, .6)))
)

p <- df %>%
  plot_geo(
    locationmode = 'country names', sizes = c(1, 600), color = I("black")
  ) %>%
  add_markers(
    y = ~Lat, x = ~Lon, locations = ~Country,
    size = ~Value, color = ~abbrev, text = ~paste(Value, "cases")
  ) %>%
  add_text(
    x = 21.0936, y = 7.1881, text = 'Africa', showlegend = F, geo = "geo2"
  ) %>%
  add_trace(
    data = df9, z = ~Month, locations = ~Country,
    showscale = F, geo = "geo2"
  ) %>%
  layout(
    title = 'Ebola cases reported by month in West Africa 2014<br> Source: <a href="https://data.hdx.rwlabs.org/dataset/rowca-ebola-cases">HDX</a>'
  )

p
