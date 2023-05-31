setwd("~/r_project/Client")

source(file = "config.R")
source(file = "arrangement.R")
source(file = "geolocation.R")
source(file = "forecasting.R")
source(file = "preparations.R")

config <- load_config()

preselected_data <- preselect_data();
prepared_data    <- download_and_prepare_data(preselected_data)
analysed_data    <- forecast_data(prepared_data)

####################################################################
# Użyte metody do prognozowania są w pliku forecasting.R. Dałam    #
# przykładowe, na luzie możecie dodać jakie tylko chcecie, które   #
# są dostępne w bibliotece forecast (można wygooglować). Myślę, że #
# możecie się teraz zająć dobraniem metod, które chcecie i         #
# napisaniem kodu sprawdzającego błędy prognozy (garsztka style) i #
# także tę mapkę z wykresami, którą chciałyście zrobić.            #
# Dla mnie refaktoring, a potem omówimy co dalej.                  #
####################################################################

# ##################################################################
# #TUTAJ! --> dane do Twojej analizy bierz z obiektu analysed_data.#
# jak wykonasz kod, to w zmiennych globalnych będziesz je widziała #
# żeby odpalić projekt musisz wykonać kod w Client\client.R, który #
# załącza automatycznie wszystkie potrzebne skrypty. Pisz swój kod #
# w tym pliku, a nie w innych, pozmieniamy to przy refaktoryzacji. #
# ##################################################################