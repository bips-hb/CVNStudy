library(readr)
library(dplyr)

# Function that take in the raw results stored 
r <- readr::read_rds("results/raw-results.rds")

#' There are different 
#'  * parameter settings for the simulation
#'  * different versions of the weight matrix
#'  * 9 graphs 
#'  * different lambda values


colnames(r)

k <- r %>% filter(job.id == 1)

get_best <- function(data, criterion = c("AIC", "BIC", "Oracle"), measure = c("F1")) { 
  
}