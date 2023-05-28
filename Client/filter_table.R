if(!require(tidyverse)) {
  install.packages("tidyverse")
  library(tidyverse)
}

setwd("~/r_test/Client")

Config <- read.delim("forecast.txt", sep = "", header = FALSE)
Remote_weather_download <- Config[Config$V1 == "URL_down",]$V2
Remote_weather_upload <- Config[Config$V1 == "URL_up",]$V2
Source_weather_ncei <- Config[Config$V1 == "URL_ncei",]$V2
Years_range <- Config[Config$V1 == "Years",]$V2
Start_year <- sapply(strsplit(Years_range, split = "-"), `[`, 1)
End_year <- sapply(strsplit(Years_range, split = "-"), `[`, 2)
Whole_range_years <- seq(Start_year, End_year, 1)

Stations <- read.csv("Data/stations.csv", sep = "")

base_data <- read.csv("Data/1931.csv.gz", header = FALSE)
data <- filter(base_data, is.element(V3, c("TMIN", "TMAX")))
data <- select(data, V1, V2, V3, V4)

data <- left_join(x = data, y = stations, by = join_by(V1 == ID))
data <- select(data, -BI, -Name)
colnames(data) <- c("WeatherStationID", "Date", "MeasurementType", "MeasurementValue", "Latitude", "Longitude", "Elevation", "WeatherStationName")
