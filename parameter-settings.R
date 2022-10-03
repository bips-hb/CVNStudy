sim_param <- dplyr::as_tibble(
  expand.grid(
    p = c(10, 50, 100, 250),  
    n_obs = c(50, 100, 250), 
    n_edges_added_x = c(10), 
    n_edges_removed_x = c(10), 
    n_edges_added_y = c(20), 
    n_edges_removed_y = c(20)
  )
)

sim_scalefree <- dplyr::as_tibble(
  expand.grid(
    type = "scale-free", 
    power = c(2,3)
  ))

sim_random <- dplyr::as_tibble(
  expand.grid(
    type = "random", 
    probability = c(.025, .05)
  ))

types <- dplyr::full_join(sim_scalefree, sim_random)

sim_param <- merge(types, sim_param)
