library(readr)
library(dplyr)

source("auxiliary.R")

# load the simulation settings 
simulation_settings <- simtracker::check_progress()

# Check if all values in the "ran" column are TRUE
if (!all(simulation_settings$ran)) {
  # If not, issue a warning
  warning("Not all results are in. Only the ones that are in will be taken into account.")
}

# Only keep the simulation settings that are done
simulation_settings <- simulation_settings %>% filter(ran)

lapply(1:nrow(simulation_settings), function(i) {
  
  parameters <- simulation_settings[i,]
  
  # read in the results
  results <- readRDS(paste0('simulations/results/', parameters$filename))
  
  
})

# Function that take in the raw results stored 
data <- readr::read_rds("results/raw-results.rds")

#' There are different 
#'  * parameter settings for the simulation
#'  * different versions of the weight matrix
#'  * different lambda values

# go over each experiment and select the lambda1, lambda2 value that 
# has either the best AIC, BIC, F1 score... whatever you want to do. 
# Do not forget to set 'maximum'!
get_best_score_per_experiment <- function(data, var = c("aic", "bic", "F1"), maximum = FALSE) { 
  if (maximum) { 
    return(
      data %>% filter(is.finite(get(var[1]))) %>% group_by(job.id, repl) %>% slice(which.max(get(var[1]))) %>% ungroup()
    )
  } else {
    return(
      data %>% filter(is.finite(get(var[1]))) %>% group_by(job.id, repl) %>% slice(which.min(get(var[1]))) %>% ungroup()
    )
  }
}


aic <- get_best_score_per_experiment(data, "aic", maximum = FALSE)
bic <- get_best_score_per_experiment(data, "bic", maximum = FALSE)
oracleF1 <- get_best_score_per_experiment(data, "F1", maximum = TRUE)
oracleHammingScaled <- get_best_score_per_experiment(data, "Hamming_scaled", maximum = FALSE)

aic$score <- "AIC"
bic$score <- "BIC"
oracleF1$score <- "OracleF1"
oracleHammingScaled$score <- "OracleHamming"

best_scores <- do.call("rbind", list(aic, bic, oracleF1, oracleHammingScaled))

readr::write_rds(best_scores, "results/best-scores.rds", compress = "gz")