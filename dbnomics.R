library(tidyverse)
library(rdbnomics)

imf_datasets <- rdb_datasets(provider_code = "IMF")[["IMF"]]
imf_dataseries <- rdb_series(provider_code = "IMF", dataset_code = "WEO:2024-10", simplify = TRUE)

imf_soldesprim <- rdb("IMF", "WEO:2024-10", mask = "FRA+ITA.GGXONLB_NGDP.pcent_gdp")
