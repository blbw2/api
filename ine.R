library(tidyverse)
library(jsonlite)
library(glue)

idioma = "EN"
función = "DATOS_TABLA"
input = c("50902")
testine <- fromJSON(glue("https://servicios.ine.es/wstempus/js/{idioma}/{función}/{input}"))# |> 
mutate(date = lubridate::ymd(paste(Anyo,FK_Periodo, sep = "-"), truncated = 1))


str(testine[[6]][[1]])

