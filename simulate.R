# generating health care claim data
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
source <- c("problems.R", "parameter-settings.R", "create-filename.R")

### Setting up the repository 
start_from_scratch <- TRUE # if true, removes all repository and creates a new one

reg_name <- "hccd_simulate"
reg_dir <- sprintf("%s/registries/%s", getwd(), reg_name)

if (start_from_scratch) { 
  dir.create("registries", showWarnings = FALSE)
  unlink(reg_dir, recursive = TRUE)
  reg <- makeRegistry(file.dir = reg_dir, packages = packages, source = source)      
} else { 
  reg <- loadRegistry(file.dir = reg_dir, writeable = TRUE)
}

batchtools::batchMap(simulator_wrapper, args = sim_param)

ids <- batchtools::findJobs(repetition < 10000)

# Submit -----------------------------------------------------------
ids <- findNotStarted()

if (grepl("node\\d{2}|bipscluster", system("hostname", intern = TRUE))) {
  ids <- findNotStarted()
  ids[, chunk := chunk(job.id, chunk.size = 50)]
  submitJobs(ids = ids, # walltime in seconds, 10 days max, memory in MB
             resources = list(name = reg_name, chunks.as.arrayjobs = TRUE,
                              memory = 80000, walltime = 10*24*3600,
                              max.concurrent.jobs = 200))
} else {
  submitJobs(ids = ids)
}

waitForJobs()