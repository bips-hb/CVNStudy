#' The Parameter Settings for the Methods and the Simulations

#' For debugging. Only a limited number of parameter settings is used, see 
#' parameter-settings.R. Only 
test_run <- FALSE

#' Parameter settings for the algorithms ------------------
algo_param <- data.frame(
  expand.grid(
    type_weight_matrix = c("full", "glasso", "grid")
  ))

#' Parameter settings for the simulation study ------------

if (test_run) { # simplify the parameters for a test run - this is debugging
  
  sim_param <- dplyr::as_tibble(
    expand.grid(
      type = c("scale-free", "random"), 
      p = c(20),  
      n_obs = c(50), 
      density = c(0.5),
      percentage_edges_x = c(.1), 
      percentage_edges_y = c(.2)
    )
  )
  
} else { # Not a test run 
  
  sim_param <- dplyr::as_tibble(
    expand.grid(
      type = c("scale-free", "random"), 
      p = c(100, 200),  
      n_obs = c(50, 100, 200), 
      density = c(0.05, 0.1),
      percentage_edges_x = c(.1, .5), 
      percentage_edges_y = c(.1, .5)
    )
  )
  
}

#' provide a specific id to each parameter setting. This makes it 
#' easier to process the results later on when there are repetitions
sim_param$sim_param_id <- 1:nrow(sim_param)
