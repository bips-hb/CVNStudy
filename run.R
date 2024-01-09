# Note: Before running this code, make sure to install the required packages listed in install-packages.R.
# You can install the packages using the following command:
# source("install-packages-github.R")

#Load the 'simtracker' package for simulation tracking
library(simtracker)
library(CVN)
library(CVNSim)

# Set up the simulation directory
simtracker::setup_simulation("cvnstudy")

# Load simulation parameter settings from an external script
source("parameter-settings.R")

# Generate simulation parameter settings with a test run (simplified parameters for debugging)
# In a test run, a limited number of parameter settings is used, and it's typically set to TRUE for debugging purposes.
# This allows for quicker testing and debugging with a smaller set of parameters.
sim_param <- generate_sim_param(test_run = FALSE)

# Number of repetitions for each set of parameters
n_repetitions <- 20

# Number of parallel workers to use (max. is 50)
n_workers <- 50

# Initialize simulation settings based on the provided parameter settings and repetitions
simulation_settings <- simtracker::initialize_simulation_settings(sim_param, n_repetitions)

# Load the function applied to each parameter setting
source("simulation-function.R")
source("process-function.R")

simulation_settings <- simtracker::check_progress()

# Set up a parallel cluster for parallel processing
cl <- simtracker::create_cluster(
  list_needed_functions_variables = list("simulation_settings",
                                         "sim_fn",
                                         "get_performance",
                                         "get_classification_scores",
                                         "adjacency_matrices_to_labels",
                                         "process_fn"),
  num_workers = n_workers
)

# Load necessary libraries on each worker in the parallel cluster
# IMPORTANT: There are no comma's between the libraries
parallel::clusterEvalQ(cl, {
  library(CVN)
  library(CVNSim)
})

# Run the simulation study using the specified function
simtracker::run_simulation_study(cl, sim_fn)

# Processes the results from the simulation study
simtracker::process_results_simulation(cl, process_fn)

# Stop and clean up the parallel cluster
simtracker::stop_cluster(cl)

# Process the results from the individual simulation runs 
source("process-results-all-runs.R")

# Uncomment the line below to delete the entire simulation directory (use with caution)
# simtracker::reset_simulation()
