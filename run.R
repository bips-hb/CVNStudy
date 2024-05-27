library(batchtools)
library(CVN)
library(CVNSim)
library(dplyr)
library(hmeasure)

options(batchtools.verbose = TRUE)
options(stringsAsFactors = FALSE)

# GLOBAL PARAMETERS ------------------------------------------------------------

set.seed(1)

# You can set the number of workers in the file batchtools.conf.R

# Debugging --------------------------

#' For debugging. Only a limited number of parameter settings is used, see
#' parameter-settings.R.
test_run <- FALSE

# Total number of replications for each parameter setting
if (test_run) {
  repls <- 1
} else {
  repls <- 20
}

# Setting up the repository ---------

#' WARNING: If TRUE, removes the current repository and creates a new one. Used
#' for debugging as well
start_from_scratch <- FALSE

#' Name of the repository
reg_name <- "cvnstudy"

#' Packages and files to load
packages = c("CVN", "CVNSim", "dplyr", "hmeasure", "batchtools")
source = c("problems.R", "algorithms.R", "parameter-settings.R",
           "create-weight-matrices.R")


#' THE EXPERIMENT ITSELF -------------------------------------------------------

reg_dir <- sprintf("%s/registries/%s", getwd(), reg_name)

if (start_from_scratch) { # remove any previously existing registry and start a new one
  dir.create("registries", showWarnings = FALSE)
  unlink(reg_dir, recursive = TRUE)
  reg <- makeExperimentRegistry(file.dir = reg_dir, packages = packages, source = source)
} else {
  reg <- loadRegistry(file.dir = reg_dir, writeable = TRUE)
}

### add problems
addProblem(name = "sim_data", fun = simulator_wrapper, seed = 1)

### add algorithms
addAlgorithm(name = "cvn", fun = cvn_wrapper)

### add the experiments

source("parameter-settings.R")
sim_param <- generate_sim_param(test_run)

# parameters for the simulation
prob_design <- list(sim_data = sim_param)

# parameters for the methods
algo_design <- list(
  cvn = algo_param
)

addExperiments(prob_design, algo_design, repls = repls)

### submit
submitJobs(resources = list(measure.memory = FALSE))

waitForJobs()


#' COLLECT THE RESULTS ---------------------------------------------------------
res <- reduceResultsList()

# combine into one big data frame
res <- do.call(rbind.data.frame, res)

# combine the results with the parameters for the job
pars <- unwrap(getJobPars())

tab <- dplyr::left_join(res, pars)

# store these results
readr::write_rds(tab, "results/raw-results.rds", compress = "gz")

# post-process the results
source("process-results.R")

# create the plots
source("plot.R")
