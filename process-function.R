#' Performance Measures
#' 
#' Determine TP, FN, FP, TN, and other classification metrics for each lambda1 and lambda2 value.
#' 
#' @param est_labels The estimated labels (binary) of the fitted model.
#' @param true_labels The true labels (binary) of the graphs.
#' 
#' @return A data frame containing various classification metrics for evaluation.
#'   - `TP`: True Positives
#'   - `FP`: False Positives
#'   - `FN`: False Negatives
#'   - `TN`: True Negatives
#'   - `total`: Total number of instances
#'   - `Hamming`: Hamming loss (sum of FP and FN)
#'   - `Hamming_scaled`: Scaled Hamming loss (Hamming loss divided by total instances)
#'   - `F1`: F1 score
#'   - `F2`: F2 score
#' 
#' @examples
#' \dontrun{
#' # Example of using get_classification_scores
#' est_labels <- c(1, 0, 1, 0, 1)
#' true_labels <- c(1, 0, 1, 1, 0)
#' scores <- get_classification_scores(est_labels, true_labels)
#' print(scores)
#' }
#'
#' @import hmeasure
#'
#' @export
get_classification_scores <- function(est_labels, true_labels) { 
  
  # use the hmeasure package for getting the classification measures
  cl <- hmeasure::misclassCounts(true_labels, est_labels)
  
  # add the TP, FP, FN, and TN values
  results <- cl$metrics
  results$TP <- cl$conf.matrix$pred.1[1]
  results$FP <- cl$conf.matrix$pred.1[2]
  results$FN <- cl$conf.matrix$pred.0[1]
  results$TN <- cl$conf.matrix$pred.0[2]
  results$total <- results$TP + results$FP + results$FN + results$TN
  results$Hamming <- results$FP + results$FN
  results$Hamming_scaled <- results$Hamming / (results$total) 
  results$F1 <- (2*results$TP) / (2*results$TP + results$FP + results$FN)
  results$F2 <- 5*(results$Precision * results$Recall) / (4*results$Precision + results$Recall)
  
  return(results)
}


#' Convert Binary Adjacency Matrices to Labels
#'
#' This function converts a list of binary adjacency matrices into a vector of labels.
#'
#' @param adj_matrices List of binary adjacency matrices.
#'
#' @return A vector of labels where each element represents the upper triangular part of the corresponding adjacency matrix.
#'
#' @examples
#' \dontrun{
#' # Example of using adjacency_matrices_to_labels
#' adjacency_matrices <- list(matrix(c(0, 1, 1, 0), nrow = 2),
#'                            matrix(c(0, 0, 1, 1, 0, 0, 1, 1, 0), nrow = 3))
#' labels <- adjacency_matrices_to_labels(adjacency_matrices)
#' print(labels)
#' }
#'
#' @export
adjacency_matrices_to_labels <- function(adj_matrices) {
  
  # number of graphs (in our simulation 9)
  m <- length(adj_matrices)
  
  labels <- sapply(1:m, function(i) { 
    adj_matrices[[i]][upper.tri(adj_matrices[[i]], diag = FALSE)]
  }) 
  
  return(labels)
}


#' Performance
#' 
#' Determines the performance of a fitted model.
#' 
#' @param fit The fitted model.
#' @param truth The ground truth (list of true graphs).
#' 
#' @return A data frame with the performance for each lambda1 and lambda2 pair.
#'   - `lambda1`: Tuning parameter lambda1 values.
#'   - `lambda2`: Tuning parameter lambda2 values.
#'   - `other_fit_parameters`: Other fit parameters from the input model.
#'   - Additional columns for classification metrics:
#'     - `TP`: True Positives
#'     - `FP`: False Positives
#'     - `FN`: False Negatives
#'     - `TN`: True Negatives
#'     - `total`: Total number of instances
#'     - `Hamming`: Hamming loss (sum of FP and FN)
#'     - `Hamming_scaled`: Scaled Hamming loss (Hamming loss divided by total instances)
#'     - `F1`: F1 score
#'     - `F2`: F2 score
#' 
#' @examples
#' \dontrun{
#' # Example of using get_performance
#' fit <- your_fitted_model
#' truth <- list_of_true_graphs
#' performance_df <- get_performance(fit, truth)
#' print(performance_df)
#' }
#'
#' @importFrom stats upper.tri
#' @export
get_performance <- function(fit, truth) { 
  
  true_labels <- adjacency_matrices_to_labels(lapply(truth, function(graph) graph$adj_matrix))
  
  # get the estimated labels for each tuning parameter setting and 
  # return the performance
  l <- lapply(1:fit$n_lambda_values, function(i) { 
    est_labels <- adjacency_matrices_to_labels(fit$adj_matrices[[i]])
    get_classification_scores(est_labels, true_labels)
  })
  
  # combine the performance scores
  l <- do.call(rbind.data.frame, l)
  cbind(fit$results, l)
}

#' Process Simulation Results for CVN Model
#' 
#' This function processes the simulation results for a CVN model using different weight matrices (full, grid, glasso).
#' It determines the performance for each lambda1 and lambda2 pair and adds a column specifying the type of weight matrix used.
#' The results for each weight matrix type are combined into a single data frame.
#' 
#' @param simulation_result The output of a CVN model simulation, typically obtained from `run_simulation`.
#' 
#' @return A data frame with the performance for each lambda1 and lambda2 pair for each weight matrix type.
#'   - `lambda1`: Tuning parameter lambda1 values.
#'   - `lambda2`: Tuning parameter lambda2 values.
#'   - `other_fit_parameters`: Other fit parameters from the CVN model.
#'   - `type_weight_matrix`: Type of weight matrix used (full, grid, glasso).
#'   - Additional columns for classification metrics:
#'     - `TP`: True Positives
#'     - `FP`: False Positives
#'     - `FN`: False Negatives
#'     - `TN`: True Negatives
#'     - `total`: Total number of instances
#'     - `Hamming`: Hamming loss (sum of FP and FN)
#'     - `Hamming_scaled`: Scaled Hamming loss (Hamming loss divided by total instances)
#'     - `F1`: F1 score
#'     - `F2`: F2 score
#' 
#' @examples
#' \dontrun{
#' # Example of using process_fn
#' simulation_result <- your_cvn_model_simulation_result
#' processed_performance <- process_fn(simulation_result)
#' print(processed_performance)
#' }
#'
#' @export
process_fn <- function(simulation_result) {
  performance_full   <- get_performance(simulation_result$fit_full, simulation_result$truth)
  performance_full$type_weight_matrix <- "full"
  
  performance_grid   <- get_performance(simulation_result$fit_grid, simulation_result$truth)
  performance_grid$type_weight_matrix <- "grid"
  
  performance_glasso <- get_performance(simulation_result$fit_glasso, simulation_result$truth)
  performance_glasso$type_weight_matrix <- "glasso"
  
  performance <- rbind(performance_full, performance_grid)
  performance <- rbind(performance, performance_glasso)
  
  performance$type_weight_matrix <- as.factor(performance$type_weight_matrix)
  
  return(performance)
}