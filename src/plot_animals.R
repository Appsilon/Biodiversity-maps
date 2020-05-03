library(sf)
library(ggplot2)
library(viridis)
library(dplyr)
library(extrafont)
library(ggiraph)
library(raster)
library(rgdal)
library(themes)
source("./src/read_data.R")
source("./src/custom_charts.R")

loadfonts()

relief <- raster("geojson/raster.tif")
relief_spdf <- as(relief, "SpatialPixelsDataFrame")
# relief is converted to a very simple data frame,  just as the fortified municipalities.
# for that we need to convert it to a SpatialPixelsDataFrame first,
# and then extract its contents using as.data.frame
relief <- as.data.frame(relief_spdf) %>% rename(value = raster)

world_geojson_loc <- file.path(getwd(), "geojson/world.geojson")
sf <- read_sf(paste0(readLines(world_geojson_loc), collapse = ""))

empty_data <- function(df) {
  all(c(df$number_species == 0, df$number_breeds == 0))
}

prepare_animal_data <- function(animal_data_raw, countries) {
  missing <- animal_data_raw[!(animal_data_raw$Country_ISO %in% countries$ISO_A3), ]
  if (!empty_data(missing)) {
    warning("Geojson does not containt polygons for some countries!")
    print(missing)
  }
  filter(animal_data_raw, !(Country_ISO %in% missing$Country_ISO)) %>%
    dplyr::select(country, number_species, number_breeds, ISO_A3)
}

cut_visible_europe <- function(sf, data) {
  sf[sf$ISO_A3 %in% data$ISO_A3, ] %>%
    sf::st_make_valid(.) %>%
    st_crop(xmin = -25, xmax = 50, ymin = 10, ymax = 70)
}

animal_data <- prepare_animal_data(animal_genetic_resources, sf)
sf_europe <- cut_visible_europe(sf, animal_data)

plot_animal <- function(sf, animal_data, target_column, interactive = FALSE) {
  target_column <- rlang::enquo(target_column)
  full_spdf <- merge(sf, animal_data, by = "ISO_A3") %>%
    filter(!!target_column > 0) %>%
    mutate(tooltip_text = paste(country, !!target_column))

  p <- ggplot(data = full_spdf) +
    # raster comes as the first layer, municipalities on top
    # geom_raster(data = relief, aes(x = x,
    #                                y = y,
    #                                alpha = value)) +
    # use the "alpha hack"
    # scale_alpha(name = "", range = c(0.6, 0), guide = F)  +
    geom_sf_interactive(aes(fill = !!target_column, tooltip = tooltip_text)) +
    scale_fill_viridis(name = "Number of animal species",
                       guide = guide_legend(keyheight = unit(3, units = "mm"),
                                             keywidth = unit(12, units = "mm"),
                                             label.position = "bottom",
                                             title.position = 'top',
                                             nrow = 1)) +
    labs(
      title = "Number of animal species",
      subtitle = "Better description"
    ) +
    theme_map()

  (if (interactive) girafe(ggobj = p) else p)
}

p <- plot_animal(sf_europe, animal_data, number_species)
p
# p <- plot_animal(sf_europe, animal_data, number_breeds)
