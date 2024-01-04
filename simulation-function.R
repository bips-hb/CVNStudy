#' Simulate Data and Apply CVN Algorithm
#' 
#' This function takes in simulation parameter settings, generates raw data using
#' the CVNSim package, and applies the CVN algorithm three times: once with a full
#' weight matrix, once with a grid weight matrix, and once with a zero weight matrix
#' (glasso). The function returns the resulting fits, the truth (ground truth graph),
#' and the raw data.
#' 
#' @param parameters A list of simulation parameters including:
#'   - \code{type}: Type of the graph, e.g., "scale-free" or "random".
#'   - \code{p}: Number of nodes in the graph.
#'   - \code{n_obs}: Number of observations in the simulated data.
#'   - \code{density}: Density of the graph.
#'   - \code{percentage_edges_x}: Percentage of edges added or removed in the x-axis direction.
#'   - \code{percentage_edges_y}: Percentage of edges added or removed in the y-axis direction.
#' 
#' @return A list containing the CVN fits for the three weight matrices, the truth graph,
#'         and the simulated raw data.
#' 
#' The function starts by extracting the simulation parameters and generating a starting
#' graph using the CVNSim::generate_graph function. It then creates a grid of graphs using
#' the CVNSim::create_grid_of_graphs function based on the starting graph and specified edge
#' percentages. Simulated data is generated from the grid using the generate_raw_data_grid
#' function. Next, the CVN algorithm is applied three times with different weight matrices
#' (full, grid, and glasso) using the CVN::CVN function. The resulting fits, along with the
#' truth graph and raw data, are returned in a list.
#'
#' Example usage:
#' \preformatted{parameters <- list(type = "scale-free", p = 100, n_obs = 200, density = 0.1,
#'                                percentage_edges_x = 0.1, percentage_edges_y = 0.2)
#' simulation_results <- sim_fn(parameters)}
#'
sim_fn <- function(parameters) {
  
  # Extract parameters
  type <- parameters$type
  p <- parameters$p
  n_obs <- parameters$n_obs
  density <- parameters$density
  percentage_edges_x <- parameters$percentage_edges_x
  percentage_edges_y <- parameters$percentage_edges_y 
  
  # generate a starting graph
  starting_graph <- CVNSim::generate_graph(p = p, type = type, density = density)
  
  # create a grid
  grid <- CVNSim::create_grid_of_graphs(starting_graph = starting_graph, 
                                        percentage_edges_added_x = percentage_edges_x, 
                                        percentage_edges_removed_x = percentage_edges_x,
                                        percentage_edges_added_y = percentage_edges_y,
                                        percentage_edges_removed_y = percentage_edges_y)   
  
  # simulated data: truth graph and generated raw data
  simulated_data <- list(
    truth = grid, 
    data = generate_raw_data_grid(n_obs, grid)  # Note: Assuming generate_raw_data_grid is defined elsewhere
  )
  
  # Apply the CVN --------------------------------------------------------------
  
  # gamma1 and gamma2 values used for the CVN
  gamma1 <- c(1e-5, 5e-5, 1e-4, 5e-4, 1e-3, 5e-3)
  gamma2 <- c(1e-5, 5e-5, 1e-4, 5e-4, 1e-3, 5e-3)
  
  # Apply the CVN algorithm for three weight matrices 
  fit_full <- CVN::CVN(simulated_data$data, 
                       CVN::create_weight_matrix(type = "full"), 
                       gamma1 = gamma1, gamma2 = gamma2, 
                       eps = 10e-4, maxiter = 1000, 
                       n_cores = 1, verbose = FALSE)
  
  fit_grid <- CVN::CVN(simulated_data$data, 
                       CVN::create_weight_matrix(type = "grid"), 
                       gamma1 = gamma1, gamma2 = gamma2, 
                       eps = 10e-4, maxiter = 1000, 
                       n_cores = 1, verbose = FALSE)
  
  fit_glasso <- CVN::CVN(simulated_data$data, 
                         CVN::create_weight_matrix(type = "glasso"), 
                         gamma1 = gamma1, gamma2 = gamma2, 
                         eps = 10e-4, maxiter = 1000, 
                         n_cores = 1, verbose = FALSE)
  
  # return all the CVN fits for the three weight matrices, and the truth and 
  # the simulated data itself
  return(
    list(
      fit_full = fit_full, 
      fit_grid = fit_grid,
      fit_glasso = fit_glasso, 
      truth = simulated_data$truth, 
      data = simulated_data$data
    )
  )
}
