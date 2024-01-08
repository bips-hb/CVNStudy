# NOTE: This script is currently designed for batchtools and needs to be 
# updated for simtracker.

# Load required libraries
library(readr)
library(dplyr)
library(ggplot2)

# Load simulation results data
data <- readr::read_rds("results/best-scores.rds")

# Load parameter settings
source("parameter-settings.R")

# Merge simulation and algorithm parameter settings
sim_param
algo_param
settings <- merge(sim_param, algo_param)

# Function to get a subset of data based on row_settings
get_subset <- function(data, row_settings) { 
  data %>% filter(
    sim_param_id == row_settings$sim_param_id, 
    type_weight_matrix == row_settings$type_weight_matrix
  )
}

# Initial subset based on the first row of settings
b = get_subset(data, settings[1,])

# Function to create a boxplot from a given data and row_settings
create_boxplot <- function(data, row_settings, var = c("F1", "F2"), 
                           xlabel = "Selection method", title = NULL) { 
  
  b <- get_subset(data, row_settings)
  
  if (is.null(title)) { 
    if (row_settings$type == "scale-free") { 
      graph_desc <- "(Scale-free)"
    } else { 
      graph_desc <- "(Erdos-Rényi)"
    }
    title <- sprintf("p = %d, n = %d, density = %g, weight matrix: %s %s", 
                     row_settings$p, 
                     row_settings$n_obs, 
                     row_settings$density, 
                     row_settings$type_weight_matrix, 
                     graph_desc)
  }
  
  ggplot(b, aes(x = score, y = get(var[1]), color = score)) + 
    geom_boxplot() + 
    xlab(xlabel) + 
    ggtitle(title) + 
    ylab(var) + 
    scale_color_brewer(palette="Dark2") + 
    theme_classic()
}

# Loop through each row in settings and create boxplots
for (i in 1:nrow(settings)) { 
  row_settings <- settings[i, ]
  
  p <- create_boxplot(data, row_settings, var = "F1")  
  
  # Generate a filename based on the row_settings
  filename <- paste0(lapply(as.list(row_settings), function(x) as.character(x)), collapse = "_")
  filename <- paste0("figures/", filename, ".pdf", collapse = "")
  
  # Save the boxplot as a PDF
  ggplot2::ggsave(
    filename,
    p,
    device = NULL,
    path = NULL,
    scale = 1,
    width = 7,
    height = 4,
    units = c("in", "cm", "mm", "px"),
    dpi = 300,
    limitsize = TRUE,
    bg = NULL
  )
}

create_boxplot(data, settings[3,])
