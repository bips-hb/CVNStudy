library(tidyverse)


fit <- readr::read_rds("results/cvnsim_1_0.025_10_50_2_2_1_24154_1")

# determine TP, FN, FP and TN for each lambda1 and lambda2 value
classification <- function(est_adj_matrix, true_adj_matrix) { 

  # get the estimated and true labels   
  est_labels <- est_adj_matrix[upper.tri(est_adj_matrix, diag = FALSE)]
  true_labels <- true_adj_matrix[upper.tri(true_adj_matrix, diag = FALSE)]
  
  # use the hmeasure package for getting the classification measures
  cl <- hmeasure::misclassCounts(true_labels, est_labels)
  
  # add the TP, FP, FN and TN values
  results <- cl$metrics
  results$TP <- cl$conf.matrix$pred.1[1]
  results$FP <- cl$conf.matrix$pred.1[2]
  results$FN <- cl$conf.matrix$pred.0[1]
  results$TN <- cl$conf.matrix$pred.0[2]
  
  return(results)
}

# get the general results and repeat them m times, one for each graph
performance <- fit$results %>% slice(rep(1:n(), each = fit$m)) 
performance$graph_id <- rep((1:fit$m), fit$n_lambda_values)

l <- lapply(1:nrow(performance), function(i) { 
    id <- performance$id[i]
    graph_id <- performance$graph_id[i]
    classification(fit$adj_matrices[[id]][[graph_id]], 
                   fit$truth[[graph_id]]$adj_matrix)
  })

l <- do.call(rbind.data.frame, l)
results <- cbind(performance, l) %>% View()
