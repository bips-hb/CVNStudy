# determine TP, FN, FP and TN for each lambda1 and lambda2 value
# used for determining the performance for a single estimated 
# adjacency matrix
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
  results$total <- results$TP + results$FP + results$FN + results$TN
  results$Hamming <- results$FP + results$FN
  results$Hamming_scaled <- results$Hamming / (results$total) 
  results$F1 <- (2*results$TP) / (2*results$TP + results$FP + results$FN)
  results$F2 <- 5*(results$Precision * results$Recall) / (4*results$Precision + results$Recall)
  
  return(results)
}


# determines the performance (true positive, true negatives etc.) 
# given the fit created by the cvn_wrapper function (see below)
# and the truth. Note that the fit and truth are stored in a file
# in the folder 'results/'
determine_performance <- function(fit) { 
  
  # get the general results and repeat them m times, one for each graph
  performance <- fit$results %>% slice(rep(1:n(), each = fit$m)) 
  performance$graph_id <- rep((1:fit$m), fit$n_lambda_values)
  
  # get the classification performance using the function classification
  results <- lapply(1:nrow(performance), function(i) { 
    id <- performance$id[i]
    graph_id <- performance$graph_id[i]
    classification(fit$adj_matrices[[id]][[graph_id]], 
                   fit$truth[[graph_id]]$adj_matrix)
  })
  
  # combine the results into a data frame
  results <- do.call(rbind.data.frame, results)
  
  # combine both data frames into one
  cbind(performance, results)
}





cvn_wrapper <- function(data, job, instance, ...) { 
  
  # problem parameters are in job$prob.pars
  print(job$prob.pars)
  print(job$algo.pars)
  print(job$seed)
  print(job)
  
  W <- create_weight_matrix(type = job$algo.pars$type_weight_matrix)
  
  # TODO: Change with type of weight matrix
  #if (job$algo.pars$type_weight_matrix == "grid") { 
  lambda1 = 1:2
  lambda2 = 1:2
  #}
  
  fit <- CVN::CVN(instance$data, W, lambda1 = lambda1, 
                  lambda2 = lambda2, eps = 10e-4, maxiter = 1000, verbose = TRUE)
  
  #print(fit)
  # add the truth 
  fit$truth <- instance$truth
  
  # save results 
  filename <- paste("results/", paste(c("cvnsim", job$prob.pars, job$algo.pars, job$seed, job$repl), collapse = '_'), sep = '')
  
  # store the fit and the truth in a file 
  readr::write_rds(fit, filename, compress = "gz")
  
  performance <- determine_performance(fit)
  performance$repl <- job$repl
  return(performance)
}

