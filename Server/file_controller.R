#* Sends File
#* @param filename The name of the file to send
#* @serializer text
#* @get /file
function(filename) {
  binary_data <- readBin(con = paste0(getwd(), "/Data/", filename), what = "raw", n = file.info(paste0(getwd(), "/Data/", filename))$size)

  base64_encode(bin = binary_data)
}

