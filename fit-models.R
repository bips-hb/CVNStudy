# fit the models to the simulated data from simulate.R
library(hccdsim)
library(hccdanalysis)
library(batchtools)
library(dplyr)
library(readr)
library(caret)
library(reshape2)
library(ggplot2)

set.seed(1)

options(batchtools.verbose = TRUE)
options(stringsAsFactors = FALSE)

### packages and files to load
packages <- c("hccdsim", "hccdanalysis", "batchtools", "dplyr", "readr", "caret", "reshape2", "ggplot2")
source <- c("parameter-settings.R", "create-filename.R")

### Setting up the repository 
start_from_scratch <- TRUE # if true, removes all repository and creates a new one

reg_name <- "hccd_fit"
reg_dir <- sprintf("%s/registries/%s", getwd(), reg_name)

if (start_from_scratch) { 
  dir.create("registries", showWarnings = FALSE)
  unlink(reg_dir, recursive = TRUE)
  reg <- makeRegistry(file.dir = reg_dir, packages = packages, source = source)      
} else { 
  reg <- loadRegistry(file.dir = reg_dir, writeable = TRUE)
}

# function for fitting the models to the simulated datasets 
wrapper <-
  function(risk_function,
           rate_withdrawal,
           peak,
           rate_long_time_after,
           delay,
           n_patients,
           simulation_time,
           ade_model,
           prescription_model,
           min_chance_drug,
           max_chance_drug,
           min_chance_ade,
           max_chance_ade,
           repetition) {

    ### determine the file name where to store the data -------
    data_filename <- create_filename(risk_function,
                                rate_withdrawal,
                                peak,
                                rate_long_time_after,
                                delay,
                                n_patients,
                                simulation_time,
                                ade_model,
                                prescription_model,
                                min_chance_drug,
                                max_chance_drug,
                                min_chance_ade,
                                max_chance_ade,
                                repetition)

    # check whether data file exists
    if (!file.exists(data_filename)) {
      stop(sprintf("data file %s does not exist", data_filename))
    }

    # determine results filename
    temp <- strsplit(data_filename, "/")
    results_filename <- paste0("results/", temp[[1]][2])

    if (file.exists(results_filename)) { # if the file already exists, you are done for this file
      return(results_filename)
    } else { # otherwise, apply all the models

      cohort <- readr::read_rds(data_filename)

      fit <- hccdanalysis::find_best_model(cohort)

      readr::write_rds(fit,
                       results_filename,
                       compress = "gz")
    }
    return(results_filename)
  }

batchtools::batchMap(wrapper, args = sim_param)

ids <- batchtools::findJobs(repetition < 10000)

# Submit -----------------------------------------------------------
if (grepl("node\\d{2}|bipscluster", system("hostname", intern = TRUE))) {
  ids <- findNotDone(ids = ids)
  ids[, chunk := chunk(job.id, chunk.size = 50)]
  submitJobs(
    ids = ids,
    # walltime in seconds, 10 days max, memory in MB
    resources = list(
      name = reg_name,
      chunks.as.arrayjobs = TRUE,
      ncpus = 1,
      memory = 64000,
      walltime = 10 * 24 * 3600,
      max.concurrent.jobs = 200
    )
  )
} else {
  ids <- findNotDone(ids = ids)
  submitJobs(ids)
}
waitForJobs()