if(!require(plumber)) {
  install.packages("plumber")
  library(plumber)
}

if(!require(openssl)) {
  install.packages("openssl")
  library(openssl)
}

setwd("~/r_project/Server")

source("../Common/parse_env.R")

env <- parse_env()

api_key <- env$value[env$key == "TOKEN"]

pr <- plumb("controllers/file_controller.R")

options_plumber(maxRequestSize = 512000000)

pr$run(port=8041)