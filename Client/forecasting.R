if(!require(dplyr)) {
    install.packages("dplyr")
    library(dplyr)
}

if(!require(forecast)) {
    install.packages("forecast")
    library(forecast)
}

if(!require(imputeTS)) {
    install.packages("imputeTS")
    library(imputeTS)
}

forecast_data <- function (stations) {
    message("")
    message("##################################################################")
    message("################# FORECASTING AND DECOMPOSITION ##################")
    message("##################################################################")
    message("")

    for (i in seq_len(length(stations))) {
        measurements <- stations[[i]]$Measurements
        station_ID <- stations[[i]]$Informations$Station_ID

        message(paste0("Creating time series for highest temperatures from station ", station_ID, "..."))
        TMAX_measurements <- measurements[measurements$MeasurementType == "TMAX",]
        TMAX_arranged_measurements <- arrange(TMAX_measurements, Year, Month)
        TMAX_time_series <- ts(TMAX_arranged_measurements$MeasurementValue, start = c(TMAX_arranged_measurements$Year[1], TMAX_arranged_measurements$Month[1]), frequency = 12)

        message(paste0("Imputing time series for highest temperatures from station ", station_ID, "..."))
        TMAX_imputed_time_series <- na_kalman(TMAX_time_series)

        message("------------------------------------------------------------------")

        message(paste0("Creating time series for lowest temperatures from station ", station_ID, "..."))
        TMIN_measurements <- measurements[measurements$MeasurementType == "TMIN",]
        TMIN_arranged_measurements <- arrange(TMIN_measurements, Year, Month)
        TMIN_time_series <- ts(TMIN_arranged_measurements$MeasurementValue, start = c(TMIN_arranged_measurements$Year[1], TMIN_arranged_measurements$Month[1]), frequency = 12)

        message(paste0("Imputing time series for lowest temperatures from station ", station_ID, "..."))
        TMIN_imputed_time_series <- na_kalman(TMIN_time_series)

        message("------------------------------------------------------------------")

        message(paste0("Forecasting next 10 year of highest temperatures from station ", station_ID, " using ARIMA..."))
        TMAX_arima_model <- auto.arima(TMAX_imputed_time_series)
        TMAX_arima_forecast <- forecast(TMAX_arima_model, h = 120)

        message(paste0("Forecasting next 10 year of highest temperatures from station ", station_ID, " using ETS..."))
        TMAX_ets_model <- ets(TMAX_imputed_time_series)
        TMAX_ets_forecast <- forecast(TMAX_ets_model, h = 120)

        message(paste0("Creating seasonal decomposition for highest temperatures from station ", station_ID, "..."))
        TMAX_decomposed_time_series <- decompose(TMAX_imputed_time_series)

        message("------------------------------------------------------------------")

        message(paste0("Forecasting next 10 year of lowest temperatures from station ", station_ID, " using ARIMA..."))
        TMIN_arima_model <- auto.arima(TMIN_imputed_time_series)
        TMIN_arima_forecast <- forecast(TMIN_arima_model, h = 120)

        message(paste0("Forecasting next 10 year of lowest temperatures from station ", station_ID, " using ETS..."))
        TMIN_ets_model <- ets(TMIN_imputed_time_series)
        TMIN_ets_forecast <- forecast(TMIN_ets_model, h = 120)

        message(paste0("Creating seasonal decomposition for lowest temperatures from station ", station_ID, "..."))
        TMIN_decomposed_time_series <- decompose(TMIN_imputed_time_series)

        message("")
        message("==================================================================")
        message("")

        stations[[i]]$Forecasts <- list(
            TMAX = list(
                ARIMA = TMAX_arima_forecast,
                ETS = TMAX_ets_forecast
            ),
            TMIN = list(
                ARIMA = TMIN_arima_forecast,
                ETS = TMIN_ets_forecast
            )
        )

        stations[[i]]$Decompositions <- list(
            TMAX = TMAX_decomposed_time_series,
            TMIN = TMIN_decomposed_time_series
        )
    }

    return(stations)
}
