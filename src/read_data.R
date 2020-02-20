library(readr)

read_gdrive_csv <- function(file_id) {
  url <- sprintf("https://docs.google.com/uc?id=%s&export=download", file_id)
  print(url)
  read_csv(url)
}

# Read AnGR_FAO_Jan2020.csv
animal_genetic_resources <- read_gdrive_csv("1ldldolY3XwJYqmp6Uoh5786Xm0umQNJf") %>%
    mutate(number_species = `Number of animal species`) %>%
    mutate(number_breeds = `Number of animal breeds`) %>%
    mutate(country = NAME_0, ISO_A3 = Country_ISO)

# forest_genetic_resources <- read_gdrive_csv("1q1lTRT-VZkl2DDT5Ekb1GqnxrhNaVKJk") # forestry_jan2020_clean2.csv
# plant_genetic_resources <- read_gdrive_csv("1rfDFNzGEl0Barm3Vhd4XzTiQa7qhegf3") # PGR_partial_Jan2020.csv

