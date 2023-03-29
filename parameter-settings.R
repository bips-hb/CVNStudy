#' The Parameter Settings for the Methods and the Simulations

#' For debugging. Only a limited number of parameter settings is used, see 
#' parameter-settings.R. Only 
test_run <- TRUE 

#' Parameter settings for the algorithms ------------------
algo_param <- data.frame(
  expand.grid(
    type_weight_matrix = c("full", "glasso", "grid")
  ))

#' Parameter settings for the simulation study ------------

if (test_run) { # simplify the parameters for a test run - this is debugging
  sim_param <- dplyr::as_tibble(
    expand.grid(
      p = c(10),  
      n_obs = c(50), 
      n_edges_x = c(10), 
      n_edges_y = c(20)
    )
  )
  
  # parameter settings for when the graph is scale-free
  sim_scalefree <- dplyr::as_tibble(
    expand.grid(
      type = "scale-free", 
      power = c(2)
    ))
  
  # parameter settings for when the graph is random
  sim_random <- dplyr::as_tibble(
    expand.grid(
      type = "random", 
      probability = c(.5)
    ))
  
  types <- dplyr::full_join(sim_scalefree, sim_random)
  
  sim_param <- merge(types, sim_param)
  
  #' provide a specific id to each parameter setting. This makes it 
  #' easier to process the results later on when there are repetitions
  sim_param$sim_param_id <- 1:nrow(sim_param)
  
} else { # Not a test run 
  
  sim_param <- dplyr::as_tibble(
    expand.grid(
      p = c(25, 50, 100, 250),  
      n_obs = c(50, 100, 250), 
      n_edges_x = c(10), 
      n_edges_y = c(20)
    )
  )
  
  # parameter settings for when the graph is scale-free
  sim_scalefree <- dplyr::as_tibble(
    expand.grid(
      type = "scale-free", 
      power = c(2,3)
    ))
  
  # parameter settings for when the graph is random
  sim_random <- dplyr::as_tibble(
    expand.grid(
      type = "random", 
      probability = c(.025, .05)
    ))
  
  types <- dplyr::full_join(sim_scalefree, sim_random)
  
  sim_param <- merge(types, sim_param)
  
  #' provide a specific id to each parameter setting. This makes it 
  #' easier to process the results later on when there are repetitions
  sim_param$sim_param_id <- 1:nrow(sim_param)
}