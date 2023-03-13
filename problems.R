# Wrapper for the CVNSim simulator 
simulator_wrapper <-
  function(job, data, type, power, probability, p, n_obs, 
           n_edges_x, n_edges_y, sim_param_id) {
    
  # generate a starting graph
  starting_graph <- CVNSim::generate_graph(p = p, type = type, 
                                             power = power, probability = probability)
    
    
  # create a grid
  grid <- CVNSim::create_grid_of_graphs(starting_graph = starting_graph, 
                                        n_edges_added_x = n_edges_x, 
                                        n_edges_removed_x = n_edges_x, 
                                        n_edges_added_y = n_edges_y, 
                                        n_edges_removed_y = n_edges_y)   
    
    
  return(
    list(
      truth = grid, 
      data = generate_raw_data_grid(n_obs, grid) 
    )
  )
}
