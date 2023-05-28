load_config <- function(){
  setwd("~/r_project/Client")
  
  Config <- read.delim("config.txt", sep = "", header = FALSE)
  Remote_weather_raw_download <- Config[Config$V1 == "URL_remote_raw_GET",]$V2
  Remote_weather_raw_upload <- Config[Config$V1 == "URL_remote_raw_POST",]$V2
  Remote_weather_processed_download <- Config[Config$V1 == "URL_remote_processed_GET",]$V2
  Remote_weather_processed_upload <- Config[Config$V1 == "URL_remote_processed_POST",]$V2
  Source_weather_ncei <- Config[Config$V1 == "URL_ncei_GET",]$V2
  Years_range <- Config[Config$V1 == "Years",]$V2
  Start_year <- sapply(strsplit(Years_range, split = "-"), `[`, 1)
  End_year <- sapply(strsplit(Years_range, split = "-"), `[`, 2)
  Whole_range_years <- seq(Start_year, End_year, 1)
}