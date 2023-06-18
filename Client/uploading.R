if(!require(openssl)) {
    install.packages("openssl")
    library(openssl)
}

if(!require(httr)) {
    install.packages("httr")
    library(httr)
}

uploadDataToServer <- function(url, data) {
    #encode data
    encoded <- base64_encode(data)

    result <- httr::POST(url = paste0(url), add_headers("api-key" = api_key, "Content-Type" = "text/plain"), body = encoded)

    if (result$status_code == 204) {
        message("File uploaded successfully")
    } else {
        warning("File upload failed")
        print(result)
    }
}