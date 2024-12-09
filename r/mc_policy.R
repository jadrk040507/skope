rm(list=ls())

library("siebanxicor")
library(dplyr)
library(purrr)
library(tidyr)

# Define your INEGI API key
setToken("86d02771fd6b64ce29912469f70d872cf666627201a5d7e819a82c452ae61289")

# Fetch the data using the specified series IDs
idSeries <- c("SF61745", "SP30578","SR14194") 

# Get the data
series <- getSeriesData(idSeries, '2010-01-01')
ref <- getSerieDataFrame(series, "SF61745")
inf <- getSerieDataFrame(series, "SP30578")
exp <- getSerieDataFrame(series, "SR14194")

series.df <- reduce(list(ref, inf, exp), full_join, by = "date")

colnames(series.df)[2:4] <- c("Tasa objetivo", "Inflación", "Inflación esperada")

series.df <- series.df %>%
  fill("Tasa objetivo", "Inflación", "Inflación esperada", .direction = "down") %>% 
  filter(date >= "2020-01-01")

series.df$"Tasa real ex-ante" = series.df$"Tasa objetivo" - series.df$"Inflación esperada"
series.df$"Tasa real ex-post" = series.df$"Tasa objetivo" - series.df$"Inflación"
 


# Specify the output directory and file name
output_dir <- "data"
output_file <- file.path(output_dir, "mc_policy.csv")
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}
write.csv(series.df, output_file, row.names = FALSE)
cat("Data successfully written to", output_file)
