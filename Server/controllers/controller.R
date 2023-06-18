template <- function (template, replacementList) {
    for (key in names(replacementList)) {
        template <- sub(paste0("%", key, "%"), replacementList[[key]], template)
    }

    return(template)
}

#* Shows the index page
#* @get /
function (req, res) {
    base_url <- paste0(req$rook.url_scheme, "://", req$HTTP_HOST)
    plot_url <- paste0(base_url, "/plot?plot=")

    stations_path <- paste0(getwd(), "/../data/stations.rds")
    station_list <- NULL
    if (file.exists(stations_path)) station_list <- readRDS(stations_path)

    document <- paste(readLines(paste0(getwd(), "/../templates/wrapper.html")), collapse = "\n")
    iframeTemplate <- paste(readLines(paste0(getwd(), "/../templates/iframe.html")), collapse = "\n")
    collapsibleTemplate <- paste(readLines(paste0(getwd(), "/../templates/collapsible.html")), collapse = "\n")

    if (is.null(station_list)) {
        message <- paste(readLines(paste0(getwd(), "/../templates/missing_data.html")), collapse = "\n")
        document <- template(document, list(
            CONTENT = message,
        ))
    } else {
        #MAPS SECTION
        TMIN_map_name <- "TMIN_map"
        TMAX_map_name <- "TMAX_map"

        TMIN_map_location <- paste0(getwd(), "/../data/plots/", TMIN_map_name, ".html")
        TMAX_map_location <- paste0(getwd(), "/../data/plots/", TMAX_map_name, ".html")

        TMIN_iframe <- NULL
        if(file.exists(TMIN_map_location)) {
            TMIN_map_url <- paste0(plot_url, TMIN_map_name)
            TMIN_iframe  <- template(iframeTemplate, list(
                SRC = TMIN_map_url,
                TYPE = "map",
                TITLE = "Mapa u&#x015B;redniodnych minimalnych temperatur w poszczeg&#x00F3;lnych miesi&#x0105;cach"
            ))
        }

        TMAX_iframe <- NULL
        if(file.exists(TMAX_map_location)) {
            TMAX_map_url <- paste0(plot_url, TMAX_map_name)
            TMAX_iframe  <- template(iframeTemplate, list(
                SRC = TMAX_map_url,
                TYPE = "map",
                TITLE = "Mapa u&#x015B;redniodnych maksymalnych temperatur w poszczeg&#x00F3;lnych miesi&#x0105;cach"
            ))
        }

        maps <- ""
        if (!is.null(TMAX_iframe) || !is.null(TMIN_iframe)) {
            maps <- paste(TMIN_iframe, TMAX_iframe, sep = "\n")
            maps <- template(collapsibleTemplate, list(
                TITLE = "Mapy temperatur na poszczeg&#x00F3;lnych stacjach pomiarowych",
                CONTENT = maps
            ))
        }

        #HISTORICAL PLOTS SECTION
        TMIN_historical_plot_name <- "TMIN_historical"
        TMAX_historical_plot_name <- "TMAX_historical"

        TMIN_historical_plot_location <- paste0(getwd(), "/../data/plots/", TMIN_historical_plot_name, ".html")
        TMAX_historical_plot_location <- paste0(getwd(), "/../data/plots/", TMAX_historical_plot_name, ".html")

        TMIN_historical_iframe <- NULL
        if(file.exists(TMIN_historical_plot_location)) {
            TMIN_historical_plot_url <- paste0(plot_url, TMIN_historical_plot_name)
            TMIN_historical_iframe  <- template(iframeTemplate, list(
                SRC = TMIN_historical_plot_url,
                TYPE = "plot",
                TITLE = "Wykres u&#x015B;redniodnych minimaplnych temperatur w poszczeg&#x00F3;lnych latach"
            ))
        }

        TMAX_historical_iframe <- NULL
        if(file.exists(TMAX_historical_plot_location)) {
            TMAX_historical_plot_url <- paste0(plot_url, TMAX_historical_plot_name)
            TMAX_historical_iframe <- template(iframeTemplate, list(
                SRC = TMAX_historical_plot_url,
                TYPE = "plot",
                TITLE = "Wykres u&#x015B;redniodnych maksymalnych temperatur w poszczeg&#x00F3;lnych latach"
            ))
        }

        historical_plots <- ""
        if (!is.null(TMAX_historical_iframe) || !is.null(TMIN_historical_iframe)) {
            historical_plots <- paste(TMIN_historical_iframe, TMAX_historical_iframe, sep = "\n")
            historical_plots <- template(collapsibleTemplate, list(
                TITLE = "Wykresy historycznych temperatur na poszczeg&#x00F3;lnych stacjach pomiarowych",
                CONTENT = historical_plots
            ))
        }

        #FORECAST PLOTS SECTION
        forecast_iframes <- ""
        for (i in seq_along(station_list)) {
            name <- station_list[[i]]
            TMIN_forecast_plot_name <- paste0("TMIN_forecasted_", name)
            TMAX_forecast_plot_name <- paste0("TMAX_forecasted_", name)

            TMIN_forecast_plot_location <- paste0(getwd(), "/../data/plots/", TMIN_forecast_plot_name, ".html")
            TMAX_forecast_plot_location <- paste0(getwd(), "/../data/plots/", TMAX_forecast_plot_name, ".html")

            print(TMIN_forecast_plot_location)

            TMIN_forecast_iframe <- NULL
            if(file.exists(TMIN_forecast_plot_location)) {
                TMIN_forecast_plot_url <- paste0(plot_url, TMIN_forecast_plot_name)
                TMIN_forecast_iframe  <- template(iframeTemplate, list(
                    SRC = TMIN_forecast_plot_url,
                    TYPE = "plot",
                    TITLE = paste0("Wykres prognozy u&#x015B;redniodnych minimalnych temperatur dla stacji ", name)
                ))
            }

            TMAX_forecast_iframe <- NULL
            if(file.exists(TMAX_forecast_plot_location)) {
                TMAX_forecast_plot_url <- paste0(plot_url, TMAX_forecast_plot_name)
                TMAX_forecast_iframe <- template(iframeTemplate, list(
                    SRC = TMAX_forecast_plot_url,
                    TYPE = "plot",
                    TITLE = paste0("Wykres prognozy u&#x015B;redniodnych maksymalnych temperatur dla stacji ", name)
                ))
            }

            forecast_plots <- ""
            if (!is.null(TMAX_forecast_iframe) || !is.null(TMIN_forecast_iframe)) {
                forecast_plots <- paste(TMIN_forecast_iframe, TMAX_forecast_iframe, sep = "\n")
                forecast_plots <- template(collapsibleTemplate, list(
                    TITLE = paste0("Wykresy prognozowanych temperatur dla stacji ", name),
                    CONTENT = forecast_plots
                ))
            }

            forecast_iframes <- paste0(forecast_iframes, forecast_plots)
        }

        document <- template(document, list(
            CONTENT = paste0(maps, historical_plots, forecast_iframes)
        ))
    }

    res$body <- document

    res$status <- 200

    res$headers <- list(
        "Content-Type" = "text/html; charset=UTF-8"
    )

    return(res)
}

#* Shows plot file
#* @get /plot
function (req, res, plot) {
    res$body <- ""

    path <- paste0(getwd(), "/../data/plots/", plot, ".html")

    if (file.exists(path)) {
        res$body <- paste(readLines(path), collapse = "\n")
        res$status <- 200
    } else {
        res$status <- 404
    }

    return(res)
}

#* Serves lib files as assets
#* @assets ../lib /lib
list()

#* Serves css files as assets
#* @assets ../css /css
list()

#* Stores file
#* parser none
#* @post /plots
function (req, res) {
    body <- req$body
    authentication <- req$HTTP_API_KEY

    res$body <- ""

    if (length(authentication) && authentication ==  api_key) {
        decoded <- base64_decode(body)
        decompressed <- memDecompress(decoded, type = "gzip")
        writeBin(object = decompressed, con = paste0(getwd(), "/../data/plots.tar"))
        untar(paste0(getwd(), "/../data/plots.tar"), exdir = paste0(getwd(), "/../data"))
        res$status <- 204
    } else {
        res$status <- 401
    }

    res$body
}


#* Stores list of stations
#* parser none
#* @post /stations
function (req, res) {
    body <- req$body
    authentication <- req$HTTP_API_KEY

    res$body <- ""

    if (length(authentication) && authentication ==  api_key) {
        decoded <- base64_decode(body)
        decompressed <- memDecompress(decoded, type = "gzip")
        writeBin(object = decompressed, con = paste0(getwd(), "/../data/stations.rds"))

        res$status <- 204
    } else {
        res$status <- 401
    }

    res$body
}