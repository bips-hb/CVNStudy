library(readr)
library(dplyr)

# Function that take in the raw results stored 
raw_results <- readr::read_rds("results/raw-results.rds")

colnames(raw_results)

get_best <- function(data, criterion = c("AIC", "BIC", "Oracle"), measure = c("F1")) { 
  
}