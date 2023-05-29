if(!require(tidyverse)) {
    install.packages("tidyverse")
    library(tidyverse)
}
if(!require(httr)) {
    install.packages("httr")
    library(httr)
}
if(!require(openssl)) {
    install.packages("openssl")
    library(openssl)
}

setwd("~/r_project/Client")
source(file = "config.R")
source(file = "filter_table.R")
source(file = "../Common/parse_env.R")

env <- parse_env()
api_key <- env$value[env$key == "TOKEN"]

config <- load_config()

stations <- read.csv(file ="Data/stations.csv", sep = "")

message(paste0("Starting preprocessing for years in range: ", config$Whole_range_years[1], " - ", config$Whole_range_years[length(config$Whole_range_years)]))

critical_error <- FALSE

for (year in config$Whole_range_years){
    message(paste0("Processing year: ", year, "."))

    message(paste0("Checking if processed data for year ", year, " is available locally..."))
    if (file.exists(paste0("Data/processed/",year,".csv.gz"))) {
        message(paste0("Data for year ", year, " has been already processed, skipping."))
        next
    }

    message(paste0("Checking if processed data for year ", year, " is available on remote server..."))
    if(!is.null(config$Remote_weather_processed_download)){
        result <- httr::HEAD(url = paste0(config$Remote_weather_processed_download, "?filename=", year), config = add_headers("api-key" = api_key, Accept = "text/plain"))
        if(result$status_code == 200) {
            message(paste0("Processed data for year ", year, " is available on remote server, downloading."))
            result <- httr::GET(url = paste0(config$Remote_weather_processed_download, "?filename=", year), add_headers("api-key" = api_key, Accept = "text/plain"))
            fileData <- content(result, as = "text", type = "text/plain", encoding = "UTF-8")
            fileData <- base64_decode(fileData)
            writeBin(object = fileData, con = paste0(getwd(), "/Data/processed/", year, ".csv.gz"))
            message(paste0("Processed data for year ", year, " has been downloaded and saved."))

            next
        }
    }

    message(paste0("Checking if raw data for year ", year, " is available locally..."))
    if (file.exists(paste0("Data/raw/",year,".csv.gz"))) {
        message(paste0("Raw data for year ", year, " is available locally, processing."))
        raw_data <- read.csv(file = paste0("Data/raw/",year,".csv.gz"), sep = ",", header = FALSE)
        processed_data <- filter_table(raw_data)
        message(paste0("Raw data for year ", year, " has been processed, saving."))
        write.csv(processed_data, file=gzfile(paste0("Data/processed/",year,".csv.gz")), row.names=FALSE)
        message(paste0("Processed data for year ", year, " has been saved."))
        if(!is.null(config$Remote_weather_processed_upload)){
            message(paste0("Uploading processed data for year ", year, " to remote server..."))
            encoded <- base64_encode(readBin(paste0("Data/processed/",year,".csv.gz"), "raw", file.size(paste0("Data/processed/",year,".csv.gz"))))
            result <- httr::POST(url = paste0(config$Remote_weather_processed_upload, "?filename=", year), add_headers("api-key" = api_key, "Content-Type" = "text/plain"), body = encoded)
            if(result$status_code == 204) {
                message(paste0("Processed data for year ", year, " has been uploaded to remote server."))
            } else {
                message(paste0("Processed data for year ", year, " has not been uploaded to remote server."))
            }
        }

        next
    }

    message(paste0("Checking if raw data for year ", year, " is available on remote server..."))
    if(!is.null(config$Remote_weather_raw_download)){
        result <- httr::HEAD(url = paste0(config$Remote_weather_raw_download, "?filename=", year), config = add_headers("api-key" = api_key, Accept = "text/plain"))
        if(result$status_code == 200) {
            message(paste0("Raw data for year ", year, " is available on remote server, downloading."))
            result <- httr::GET(url = paste0(config$Remote_weather_raw_download, "?filename=", year), add_headers("api-key" = api_key, Accept = "text/plain"))
            fileData <- content(result, as = "text", type = "text/plain", encoding = "UTF-8")
            fileData <- base64_decode(fileData)
            message(paste0("Raw data for year ", year, " has been downloaded, saving and processing."))
            writeBin(object = fileData, con = paste0(getwd(), "/Data/raw/", year, ".csv.gz"))

            raw_data <- read.csv(file = paste0("Data/raw/",year,".csv.gz"), sep = ",", header = FALSE)
            processed_data <- filter_table(raw_data)
            message(paste0("Raw data for year ", year, " has been processed, saving."))
            write.csv(processed_data, file=gzfile(paste0("Data/processed/",year,".csv.gz")), row.names=FALSE)
            message(paste0("Processed data for year ", year, " has been saved."))
            if(!is.null(config$Remote_weather_processed_upload)){
                message(paste0("Uploading processed data for year ", year, " to remote server..."))
                encoded <- base64_encode(readBin(paste0("Data/processed/",year,".csv.gz"), "raw", file.size(paste0("Data/processed/",year,".csv.gz"))))
                result <- httr::POST(url = paste0(config$Remote_weather_processed_upload, "?filename=", year), add_headers("api-key" = api_key, "Content-Type" = "text/plain"), body = encoded)
                if(result$status_code == 204) {
                    message(paste0("Processed data for year ", year, " has been uploaded to remote server."))
                } else {
                    message(paste0("Processed data for year ", year, " has not been uploaded to remote server."))
                }
            }

            next
        }
    }

    message(paste0("Checking if raw data for year ", year, " is available on source server..."))
    if(!is.null(config$Source_weather_ncei)){
        result <- httr::HEAD(url = paste0(config$Source_weather_ncei, year, ".csv.gz"))
        if(result$status_code == 200) {
            message(paste0("Raw data for year ", year, " is available on source server, downloading."))
            result <- httr::GET(url = paste0(config$Source_weather_ncei, year, ".csv.gz"))
            fileData <- content(result, as = "raw", type = "application/gzip", encoding = "UTF-8")
            if(!is.null(fileData)) {
                message(paste0("Raw data for year ", year, " has been downloaded, saving and processing."))
                writeBin(object = fileData, con = paste0(getwd(), "/Data/raw/", year, ".csv.gz"))
                if(!is.null(config$Remote_weather_raw_upload)){
                    message(paste0("Uploading raw data for year ", year, " to remote server..."))
                    encoded <- base64_encode(readBin(paste0("Data/raw/",year,".csv.gz"), "raw", file.size(paste0("Data/raw/",year,".csv.gz"))))
                    result <- httr::POST(url = paste0(config$Remote_weather_raw_upload, "?filename=", year), add_headers("api-key" = api_key, "Content-Type" = "text/plain"), body = encoded)
                    if(result$status_code == 204) {
                        message(paste0("Raw data for year ", year, " has been uploaded to remote server."))
                    } else {
                        message(paste0("Raw data for year ", year, " has not been uploaded to remote server."))
                    }
                }
                raw_data <- read.csv(file = paste0("Data/raw/",year,".csv.gz"), sep = ",", header = FALSE)
                processed_data <- filter_table(raw_data)
                message(paste0("Raw data for year ", year, " has been processed, saving."))
                write.csv(processed_data, file=gzfile(paste0("Data/processed/",year,".csv.gz")), row.names=FALSE)
                message(paste0("Processed data for year ", year, " has been saved."))
                if(!is.null(config$Remote_weather_processed_upload)){
                    message(paste0("Uploading processed data for year ", year, " to remote server..."))
                    encoded <- base64_encode(readBin(paste0("Data/processed/",year,".csv.gz"), "raw", file.size(paste0("Data/processed/",year,".csv.gz"))))
                    result <- httr::POST(url = paste0(config$Remote_weather_processed_upload, "?filename=", year), add_headers("api-key" = api_key, "Content-Type" = "text/plain"), body = encoded)
                    if(result$status_code == 204) {
                        message(paste0("Processed data for year ", year, " has been uploaded to remote server."))
                    } else {
                        message(paste0("Processed data for year ", year, " has not been uploaded to remote server."))
                    }
                }
                next
            } else {
                critical_error <- TRUE
                break
            }
        }
    }
}

if(critical_error) {
    stop(paste0("Critical error occured. No data available for year ", year, "."))
}