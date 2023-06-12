# Wrapper for the CVNSim simulator 
simulator_wrapper <-
  function(job, data, type, p, n_obs, density, percentage_edges_x, 
           percentage_edges_y, sim_param_id) {
    
  # generate a starting graph
  starting_graph <- CVNSim::generate_graph(p = p, type = type, density = density)
    
    
  # create a grid
  grid <- CVNSim::create_grid_of_graphs(starting_graph = starting_graph, 
                                        percentage_edges_added_x = percentage_edges_x, 
                                        percentage_edges_removed_x = percentage_edges_x,
                                        percentage_edges_added_y = percentage_edges_y,
                                        percentage_edges_removed_y = percentage_edges_y)   
  
  res <- list(
    truth = grid, 
    data = generate_raw_data_grid(n_obs, grid) 
  )  

  
  filename <- sprintf("data/%s_p%d_n%d_density%g_percx%g_percy%g_id%d.rds", 
                      type, 
                      p, 
                      n_obs, 
                      density,
                      percentage_edges_x, 
                      percentage_edges_y,
                      sim_param_id)
    
  readr::write_rds(res, filename, compress = "gz")
  
  return(res)
}
