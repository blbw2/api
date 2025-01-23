
## queries must not end with "/"
testons <- fromJSON("https://api.beta.ons.gov.uk/v1/datasets")
testons <- fromJSON("https://api.beta.ons.gov.uk/v1/datasets/regional-gdp-by-year/editions/time-series/versions/6")

onsdata <- read.csv("https://download.beta.ons.gov.uk/downloads/datasets/cpih01/editions/time-series/versions/54.csv") |> 
  mutate(date = my(Time))