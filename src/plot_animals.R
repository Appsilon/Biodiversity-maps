library(sf)
library(ggplot2)
library(viridis)
library(dplyr)
source("./src/read_data.R")

world_geojson_loc <- file.path(getwd(), "geojson/world.geojson")
gsf <- read_sf(paste0(readLines(world_geojson_loc), collapse = ""))

empty_data <- function(df) {
  all(c(df$"Number of animal species" == 0, df$"Number of animal breeds" == 0))
}

missing <- animal_genetic_resources[!(animal_genetic_resources$Country_ISO %in% gsf$ISO_A3), ]
if (!empty_data(missing)) {
  warning("Geojson don't have shapefiles for non-empty countries!")
  print(missing)
}

animal_genetic_clean <- filter(animal_genetic_resources, !(Country_ISO %in% missing$Country_ISO))
gsf_europe <- gsf[gsf$ISO_A3 %in% animal_genetic_clean$Country_ISO, ]

animal_short <- animal_genetic_clean %>%
  mutate(number_species = `Number of animal species`) %>%
  mutate(number_breeds = `Number of animal breeds`) %>%
  select(Country_ISO, number_species, number_breeds)

full_spdf <- merge(gsf_europe, animal_short, by.x = "ISO_A3", by.y = "Country_ISO") %>%
  filter(number_species > 0)

ggplot(data = full_spdf) +
  geom_sf(aes(fill = number_species)) +
  theme_void() +
  scale_fill_viridis(breaks = c(1,5,10,20,50,100), name = "Number of animal species", guide = guide_legend(keyheight = unit(3, units = "mm"), keywidth = unit(12, units = "mm"), label.position = "bottom", title.position = 'top', nrow = 1)) +
  labs(
    title = "South of France Restaurant concentration",
    subtitle = "Number of restaurant per city district"
  ) +
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "#f5f5f2", color = NA),
    legend.background = element_rect(fill = "#f5f5f2", color = NA),

    plot.title = element_text(size= 22, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 17, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),

    legend.position = c(1.7, 0.99)
  )
