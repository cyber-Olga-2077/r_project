if(!require(htmlwidgets)) {
    install.packages("htmlwidgets")
    library(htmlwidgets)
}

createDirectory <- function() {
    if (!dir.exists("plots")) {
        dir.create("plots")
    }
}

saveYearlyPlots <- function(plots) {
    message("Saving yearly plots...")
    saveWidget(plots$TMAX, file = "plots/TMAX_historical.html", selfcontained = FALSE, libdir = "lib")
    saveWidget(plots$TMIN, file = "plots/TMIN_historical.html", selfcontained = FALSE, libdir = "lib")
}

saveMonthlyPlots <- function(plots) {
    message("Saving monthly plots...")
    for (i in seq(1, length(plots))) {
        message("Saving ", plots[[i]]$Name, "...")
        saveWidget(plots[[i]]$TMAX, file = paste0("plots/TMAX_forecasted_", plots[[i]]$Name, ".html"), selfcontained = FALSE, libdir = "lib")
        saveWidget(plots[[i]]$TMIN, file = paste0("plots/TMIN_forecasted_", plots[[i]]$Name, ".html"), selfcontained = FALSE, libdir = "lib")
    }
}

saveMaps <- function(maps) {
    message("Saving maps...")
    saveWidget(maps$TMAX, file = "plots/TMAX_map.html", selfcontained = FALSE, libdir = "lib")
    saveWidget(maps$TMIN, file = "plots/TMIN_map.html", selfcontained = FALSE, libdir = "lib")
}