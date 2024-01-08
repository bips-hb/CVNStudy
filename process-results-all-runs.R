# NOTE: This script combines all the results of individual simulation runs. 
# It uses the results produced by the simtracker::process_results_simulation 
# function and puts all the results into a single file, in this case, 'best-scores.rds'.

library(readr)
library(dplyr)

# Load the data --------------------------------------------

# Check if the file "simulations/processed-results.rds" exists
if (file.exists("simulations/processed-results.rds")) {
  # Read in the results
  results <- readRDS("simulations/processed-results.rds")
  
} else {
  # If the file does not exist, print an error message
  stop("Error: 'simulations/processed-results.rds' not found. Make sure the file exists.")
}

# Combine it in a single tibble ------------------------------
data <- dplyr::bind_rows(results, .id = "job.id")


#' There are different 
#'  * parameter settings for the simulation
#'  * different versions of the weight matrix
#'  * different lambda values


#' Get Best Score per Experiment
#'
#' This function iterates over each experiment and selects the optimal lambda1, lambda2 value
#' based on user-defined criteria such as AIC, BIC, F1 score, etc.
#'
#' @param data A tibble or data frame containing experiment results.
#' @param var A character vector specifying the variable to optimize (e.g., "aic", "bic", "F1").
#' @param maximum A logical value indicating whether to select the maximum or minimum value for optimization.
#'
#' @return A tibble containing the optimal lambda1, lambda2 values for each experiment based on the specified criterion.
#'
#' @examples
#' \dontrun{
#' # Example of using get_best_score_per_experiment
#' optimal_values <- get_best_score_per_experiment(experiment_data, var = "F1", maximum = TRUE)
#' print(optimal_values)
#' }
#'
#' @import dplyr
#'
#' @export
get_best_score_per_experiment <- function(data, var = c("aic", "bic", "F1"), maximum = FALSE) { 
  if (maximum) { 
    # Select the row with the maximum value for the specified variable
    return(
      data %>% filter(is.finite(get(var[1]))) %>% group_by(job.id, replication) %>% slice(which.max(get(var[1]))) %>% ungroup()
    )
  } else {
    # Select the row with the minimum value for the specified variable
    return(
      data %>% filter(is.finite(get(var[1]))) %>% group_by(job.id, replication) %>% slice(which.min(get(var[1]))) %>% ungroup()
    )
  }
}

# Get the CVN model with the minimum AIC value
aic <- get_best_score_per_experiment(data, "aic", maximum = FALSE)

# Get the CVN model with the minimum BIC value
bic <- get_best_score_per_experiment(data, "bic", maximum = FALSE)

# Get the CVN model with the maximum F1 score (Oracle F1)
oracleF1 <- get_best_score_per_experiment(data, "F1", maximum = TRUE)

# Get the CVN model with the minimum Hamming distance (scaled)
oracleHammingScaled <- get_best_score_per_experiment(data, "Hamming_scaled", maximum = FALSE)

# Add a new column 'score' to each result indicating the optimization criterion
aic$score <- "AIC"
bic$score <- "BIC"
oracleF1$score <- "OracleF1"
oracleHammingScaled$score <- "OracleHamming"

# Combine the results into a single tibble
best_scores <- do.call("rbind", list(aic, bic, oracleF1, oracleHammingScaled))

# Write the combined results to an RDS file
readr::write_rds(best_scores, "simulations/best-scores.rds", compress = "gz")
