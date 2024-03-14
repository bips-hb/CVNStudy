#' Generate Simulation Parameter Settings
#' 
#' This function generates parameter settings for simulations based on specified 
#' conditions, allowing for a test run with simplified parameters for debugging.
#' 
#' @param test_run Logical indicating whether to use simplified parameters for a 
#'                 test run (default is FALSE).
#' 
#' @return A tibble containing parameter settings for the simulation study.
generate_sim_param <- function(test_run = FALSE) {
  
  if (test_run) { # simplify the parameters for a test run - this is for debugging
    
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
        n_obs = c(100, 200), 
        density = c(0.1),
        percentage_edges_x = c(.1, .2), 
        percentage_edges_y = c(.1, .2)
      )
    )
    
  }
  
  #' provide a specific id to each parameter setting. This makes it 
  #' easier to process the results later on when there are repetitions
  sim_param$sim_param_id <- 1:nrow(sim_param)
  
  return(sim_param)
}
