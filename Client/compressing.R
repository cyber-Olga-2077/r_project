removeLibraryFiles <- function () {
    if (dir.exists("plots/lib")) {
        unlink("plots/lib", recursive = TRUE)
    }
}

tarPlots <- function () {
    message("Archiving plots...")
    tar("plots.tar", "plots")
}

compressPlots <- function () {
    removeLibraryFiles()
    tarPlots()

    message("Compressing plots...")
    toCompress <- readBin("plots.tar", what = "raw", n = file.info("plots.tar")$size)
    compressed <- memCompress(toCompress, type = "gzip")
    unlink("plots.tar")

    return(compressed)
}

stations <- analysed_data

compressStationList <- function (stations) {
    names <- lapply(stations, function (station) {
        return(station$Informations$Station_ID)
    })

    names <- memCompress(serialize(names, NULL), type = "gzip")

    return(names)
}