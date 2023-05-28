#* Returns file
#* @param filename The name of the file to send
#* @serializer text
#* parser none
#* @get /file/processed
function(req, res, filename) {
  authentication <- req$HTTP_API_KEY

  res$body <- ""

  if (!is.null(authentication) && authentication ==  api_key) {
    binary_data <- readBin(con = paste0(getwd(), "/../data/processed/", filename, ".csv.gz"), what = "raw", n = file.info(paste0(getwd(), "/../Data/processed/", filename, ".csv.gz"))$size)
    res$body <- base64_encode(bin = binary_data)

    res$status <- 200
  } else {
    res$status <- 401
  }

  res$body
}

#* Stores file
#* parser none
#* @post /file/processed
function (req, res, filename) {
  body <- req$body
  authentication <- req$HTTP_API_KEY

  res$body <- ""

  if (length(authentication) && authentication ==  api_key) {
    decoded <- base64_decode(body)
    writeBin(object = decoded, con = paste0(getwd(), "/../data/processed/", filename, ".csv.gz"))

    res$status <- 204
  } else {
    res$status <- 401
  }

  res$body
}

#* Returns file
#* @param filename The name of the file to send
#* @serializer text
#* parser none
#* @get /file/raw
function(req, res, filename) {
  authentication <- req$HTTP_API_KEY

  res$body <- ""

  if (!is.null(authentication) && authentication ==  api_key) {
    binary_data <- readBin(con = paste0(getwd(), "/../data/raw/", filename, ".csv.gz"), what = "raw", n = file.info(paste0(getwd(), "/../Data/raw/", filename, ".csv.gz"))$size)
    res$body <- base64_encode(bin = binary_data)

    res$status <- 200
  } else {
    res$status <- 401
  }

  res$body
}

#* Stores file
#* parser none
#* @post /file/raw
function (req, res, filename) {
  body <- req$body
  authentication <- req$HTTP_API_KEY

  res$body <- ""

  if (!is.null(authentication) && authentication ==  api_key) {
    decoded <- base64_decode(body)
    writeBin(object = decoded, con = paste0(getwd(), "/../data/raw/", filename, ".csv.gz"))

    res$status <- 204
  } else {
    res$status <- 401
  }

  res$body
}
