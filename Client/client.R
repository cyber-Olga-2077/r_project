if(!require(tidyverse)) {
  install.packages("tidyverse")
  library(tidyverse)
}
if(!require(httr)) {
  install.packages("httr")
  library(httr)
}

setwd("~/r_project/Client")
source(file = "config.R")
source(file = "filter_table.R")
source("../Common/parse_env.R")

env <- parse_env()
load_config()


stations <- read.csv("Data/stations.csv", sep = "")

for (year in Whole_range_years){
  if (file.exists(paste0("Data/processed/",year,".csv.gz"))){
    next 
  }
  
  if(!is.null(Remote_weather_processed_download)){
    result <- httr::GET(url = paste0(Remote_weather_processed_download, "?filename=", year))
    print(result)
  }
  
}