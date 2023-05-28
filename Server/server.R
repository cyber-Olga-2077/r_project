if(!require(plumber)) {
  install.packages("plumber")
  library(plumber)
}

if(!require(openssl)) {
  install.packages("openssl")
  library(openssl)
}

setwd("~/r_test/Server")

pr <- plumb("file_controller.R")
pr$run(port=8000)