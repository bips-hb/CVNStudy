cvn_wrapper <- function(data, job, instance, ...) { 
  
  # problem parameters are in job$prob.pars
  print(job$prob.pars)
  print(job$algo.pars)
  print(job$seed)
  
  W <- create_weight_matrix(type = job$algo.pars$type_weight_matrix)
  
  if (job$algo.pars$lambda_choice == "grid") { 
    lambda1 = 1:2
    lambda2 = 1:2
  }
  
  fit <- CVN::CVN(instance$data, W, lambda1 = lambda1, 
                  lambda2 = lambda2, eps = 10e-4, maxiter = 1000, verbose = TRUE)
  
  #print(fit)
  fit$truth <- instance$truth
  
  # save results 
  filename <- paste("results/", paste(c("cvnsim", job$prob.pars, job$algo.pars, job$seed), collapse = '_'), sep = '')
  
  saveRDS(fit, filename)
  
  return(fit)
}

