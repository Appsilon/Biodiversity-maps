library(sf)
library(ggplot2)
library(viridis)
library(dplyr)
library(extrafont)
source("./src/read_data.R")

loadfonts()

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
gsf_europe <- gsf[gsf$ISO_A3 %in% animal_genetic_clean$Country_ISO, ] %>%
  lwgeom::st_make_valid(.) %>%
  st_crop(xmin = -25, xmax = 50, ymin = 10, ymax = 70)

animal_short <- animal_genetic_clean %>%
  mutate(number_species = `Number of animal species`) %>%
  mutate(number_breeds = `Number of animal breeds`) %>%
  mutate(country = NAME_0, ISO_A3 = Country_ISO) %>%
  select(country, ISO_A3, number_species, number_breeds)

full_spdf <- merge(gsf_europe, animal_short, by = "ISO_A3") %>%
  filter(number_species > 0) %>%
  mutate(tooltip_text = paste(country, number_species))

theme_map <- function(...) {
  theme_minimal() +
  theme(
    text = element_text(family = "Maven Pro", color = "#22211d"),
    axis.line = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    # panel.grid.minor = element_line(color = "#ebebe5", size = 0.2),
    panel.grid.major = element_line(color = "#ebebe5", size = 0.2),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "#f5f5f2", color = NA),
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.border = element_blank(),
    ...
  )
}

p <- ggplot(data = full_spdf) +
  geom_sf_interactive(aes(fill = number_species, tooltip = tooltip_text)) +
  scale_fill_viridis(name = "Number of animal species", guide = guide_legend(keyheight = unit(3, units = "mm"), keywidth = unit(12, units = "mm"), label.position = "bottom", title.position = 'top', nrow = 1)) +
  labs(
    title = "Number of animal species",
    subtitle = "Better description"
  ) +
  theme_map()
p
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "#f5f5f2", color = NA),
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    plot.title = element_text(size = 22, hjust = 0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size = 17, hjust = 0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    legend.position = c(0.5, 0.1)
  )
p

# Interactive version:
library(ggiraph)
girafe(ggobj = p)
