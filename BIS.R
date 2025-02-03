library(tidyverse)
library(rsdmx)
library(jsonlite)


bis_datasets <- readSDMX("https://stats.bis.org/api/v2/dataset/BIS")
bis_datasets <- readSDMX(providerId = "BIS", resource = )


test <- data.frame(readSDMX("https://stats.bis.org/api/v2/data/dataflow/BIS/WS_CBS_PUB/1.0/Q.S.5A.4B.F.C.A.A.TO1.A.5J"))


test <- (readSDMX("https://stats.bis.org/api/v2/data/dataflow/?all"))

test <- readSDMX("https://stats.bis.org/api/v2/structure/dataflow/BIS/*/1.0")
test <- fromJSON("https://stats.bis.org/api/v2/structure/dataflow/BIS/*/1.0")

BIS_dataflows <- test[["data"]][["dataflows"]]
