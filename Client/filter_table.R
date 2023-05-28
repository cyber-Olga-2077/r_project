
filter_table <- function(input_data){
  
  data <- filter(input_data, is.element(V3, c("TMIN", "TMAX")))
  data <- select(data, V1, V2, V3, V4)
  
  data <- left_join(x = data, y = stations, by = join_by(V1 == ID))
  data <- select(data, -BI, -Name)
  colnames(data) <- c("WeatherStationID", "Date", "MeasurementType", "MeasurementValue", "Latitude", "Longitude", "Elevation", "WeatherStationName")
  data <- filter(data, WeatherStationName != "")
  
}

# base_data <- read.csv("Data/raw/1931.csv.gz", header = FALSE)

# write.csv(data, file=gzfile("Data/processed/1931.csv.gz"))