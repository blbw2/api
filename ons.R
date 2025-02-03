library(jsonlite)
library(tidyverse)
library(openxlsx)
library(data.table)
library(glue)

## queries must not end with "/"
testons <- fromJSON("https://api.beta.ons.gov.uk/v1/datasets")
testons <- fromJSON("https://api.beta.ons.gov.uk/v1/datasets/regional-gdp-by-year/editions/time-series/versions/6")

onsdata <- read.csv("https://download.beta.ons.gov.uk/downloads/datasets/cpih01/editions/time-series/versions/54.csv") |> 
  mutate(date = my(Time))


ons_search <- fromJSON("https://api.beta.ons.gov.uk/v1/search?content_type=timeseries&amp;cdids=JP9Z")

ons_search3 <- fromJSON("https://api.beta.ons.gov.uk/v1/search?topic=earnings")

ons_emp <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/timeseries/")

ons_topics <- fromJSON("https://api.beta.ons.gov.uk/v1/navigation")

ons_empsubtopic <- fromJSON("https://api.beta.ons.gov.uk/v1/topics/employmentandlabourmarket")


ons_empts <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/timeseries/jp9z/lms/previous/v108")

test <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/datasets/labourmarketstatistics/current")

test2 <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/averageweeklyearningsearn01")

search_awe <- fromJSON("https://api.beta.ons.gov.uk/v1/search?content_type=timeseries;cdids=KAB9")

ons_awe <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peopleinwork/earningsandworkinghours/timeseries/kab9/emp")

"https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/timeseries/lf2o/lms"

testpop <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/timeseries/lf2o/lms")[["months"]]

conso_ons <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/economy/nationalaccounts/satelliteaccounts/timeseries/abpb/bb")


pib_uk <- data.frame(readSDMX("https://sdmx.oecd.org/public/rest/data/OECD.SDD.NAD,DSD_NAMAIN1@DF_QNA_EXPENDITURE_USD,1.1/Q..GBR.S1+S13+S1M..P7+P6+P51G+P3+B1GQ.....LR+V..?startPeriod=2023-Q3&dimensionAtObservation=AllDimensions"))



# Emploi (datastream) -----------------------------------------------------

## lecture des identifiants de série

emp_datastream <-read.xlsx("data_uk/emploi_datastream.xlsx", sheet = "ONS_aou24") |> 
  select(-contains("Title")) |> 
  data.table()

emp_seriesID <- emp_datastream[1,] |> 
  select_if(~ !any(is.na(.))) |> 
  t()

emp_seriesID_vector <- str_to_lower(as.vector(emp_seriesID))


uk_emp <- list()

for (i in 1:length(emp_seriesID_vector)){
  id <- emp_seriesID_vector[[i]]
  uk_emp[[i]] <- fromJSON(glue("https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/timeseries/{id}/lms"))[["months"]]
  
}

uk_chom <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/employmentandlabourmarket/peoplenotinwork/unemployment/timeseries/lf2i/lms")[["months"]]



# PIB ---------------------------------------------------------------------

pib_series <- read.xlsx("data_uk/RESEMP.xlsx", sheet = "pibvol_id_qna_ukea") |> 
  data.table()

pib_seriesid <- pib_series[1,]|> 
  t() |> 
  data.frame() |> 
  rename(id =1) |> 
  mutate(id = str_extract(id, "^UK(\\w{4}).+$", group =1))

pib_seriesid_vector <- as.vector(str_to_lower(pib_seriesid$id))


test <- fromJSON("https://api.beta.ons.gov.uk/v1/data?uri=/economy/grossdomesticproductgdp/timeseries/l635/qna")

##non-sat accounts
uk_resemp_vol <- list()

for (i in 1:length(pib_seriesid_vector)){
  id <- pib_seriesid_vector[[i]]
  uk_resemp_vol[[id]] <- fromJSON(glue("https://api.beta.ons.gov.uk/v1/data?uri=/economy/grossdomesticproductgdp/timeseries/{id}/qna"))[["quarters"]]
  
}



## sat accounts

##abjr = conso menages
uk_resemp_vol <- list()

for (i in 1:length(pib_seriesid_vector)){
  id <- pib_seriesid_vector[[i]]
  uk_resemp_vol[[i]] <- fromJSON(glue("https://api.beta.ons.gov.uk/v1/data?uri=/economy/grossdomesticproductgdp/timeseries/{id}/qna"))[["quarters"]]
  
}



uk_resemp_vol <- fromJSON(glue("https://api.beta.ons.gov.uk/v1/data?uri=/economy/grossdomesticproductgdp/timeseries/{i}/qna"))[["quarters"]]


test <- "UKABMI..D	UKABJR..D	UKhAYO..D	UKNMRY..D	UKNPQT...D	UKNPEL..D	UKDFEG..D	UKDLWF..D	UKL635..D	UKL637..D	UKCAFU..D	UKNPJR..D	UKYBIM..D	UKIKBK..D	UKIKBL..D	UKGIXSQ.D	UKABMG..D																									volume																							"

test2 <- ("UKABMI..D	UKABJR..D	UKhAYO..D	UKNMRY..D	UKNPQT..D	UKNPEL..D	UKDFEG..D	UKDLWF..D	UKL635..D	UKL637..D	UKCAFU..D	UKNPJR..D	UKYBIM..D	UKIKBK..D	UKIKBL..D	UKGIXSQ.D	UKABMG..D")
str_split_1(test2, "\\t")
