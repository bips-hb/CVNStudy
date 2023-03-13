# CVN Simulation Study

## Included files:
* `run.R`: Script to run entire simulation study
* `config.R` and `torque.tmpl`: Config for the BIPS cluster -- don't change. See below.

## Setup

You'll need some R packages: 

```r
install.packages(c("CVN", "CVNSim", "tidyverse", "hmeasure", "batchtools", "ggplot2"))
source("install-packages-github.R")
```

## First time cluster setup

- To use R, you have to load the R module on the cluster:
  - List available R versions: `module avail R`
  - Before loading an R module, you need `mpi`: `module load mpi/openmpi/1.8.5`
- Automatically load modules on login by adding the following to your `~/.bashrc`:

```sh
module load mpi/openmpi/1.8.5
module load R/4.0.2
module list
```

- Copy the config files `config.R` and `torque.tmpl` from above to your configuration directory:

```sh
# create directory if needed
mkdir -p ~/.config/batchtools/
cp  config.R ~/.config/batchtools/
cp  torque.tmpl ~/.config/batchtools/
```

# More info on the cluster, see: 

- https://mllg.github.io/batchtools/index.html
- https://github.com/bips-hb/batchtools_example
