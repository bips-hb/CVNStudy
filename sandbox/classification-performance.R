library(tidyverse)


fit <- readr::read_rds("results/cvnsim_1_0.025_10_50_2_2_1_24154_1")


# turn a list of adjencency matrices in a vector of binary labels
get_all_labels <- function(adj_matrices) { 
  # go over all graphs
  sapply(1:length(adj_matrices), function(i) { 
    adj_matrices[[i]][upper.tri(adj_matrices[[i]], diag = FALSE)]
  })  
}

# get all the adjacency matrices of fit$truth
get_adj_matrices_truth <- function(truth) { 
  m <- length(truth)  
  lapply(1:m, function(i) { 
    truth[[i]]$adj_matrix 
  })
}

# determine TP, FN, FP and TN for each lambda1 and lambda2 value
get_classification_scores <- function(est_labels, true_labels) { 
  
  # use the hmeasure package for getting the classification measures
  cl <- hmeasure::misclassCounts(true_labels, est_labels)
  
  # add the TP, FP, FN and TN values
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

get_performance <- function(fit) { 
  
  # get the true labels
  true_labels <- get_all_labels(get_adj_matrices_truth(fit$truth))
  
  # get the estimated labels for each tuning parameter setting and 
  # return the performance
  l <- lapply(1:fit$n_lambda_values, function(i) { 
      est_labels <- get_all_labels(fit$adj_matrices[[i]])
      get_classification_scores(est_labels, true_labels)
    })
  
  l <- do.call(rbind.data.frame, l)
  cbind(fit$results, l)
}

get_performance(fit)
