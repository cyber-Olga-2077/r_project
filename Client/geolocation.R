if(!require(sp)) {
    install.packages("sp")
    library(sp)
}

if(!require(rworldmap)) {
    install.packages("rworldmap")
    library(rworldmap)
}

coords_to_continent <- function (points) {
    map <- getMap(resolution = "low")
    spatial_points <- SpatialPoints(points, proj4string = CRS(proj4string(map)))
    indices <- over(spatial_points, map)
    regions <- indices$REGION
    return(regions)
}