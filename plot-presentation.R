# create all figures  

library(readr)
library(dplyr)
library(ggplot2)

# load data
data <- readr::read_rds("results/best-scores.rds")

data <- data %>% filter(score != "OracleHamming") 

data$type_weight_matrix <- as.character(data$type_weight_matrix)
data$type_weight_matrix[data$type_weight_matrix == 'glasso'] <- 'no smoothing'
data$type_weight_matrix[data$type_weight_matrix == 'full'] <- 'fully connected'
data$type_weight_matrix <- as.factor(data$type_weight_matrix)


boxplot_cvn <- function(d, title = "") {
ggplot(d, aes(x = factor(type_weight_matrix, level = c("no smoothing", "grid", "fully connected")) , y = F1, color = type_weight_matrix)) + 
  geom_boxplot() + 
  xlab("weight matrix") + 
  ggtitle(title) + 
  ylab("best F1 score") + 
  ylim(0.26, .83) +
  scale_color_brewer(palette="Dark2") + 
  theme_bw() + 
  theme(legend.position = "none")  
}

d <- data %>% filter(
  p == 100, 
  n_obs == 200, 
  density == 0.1, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "random", 
  score == "OracleF1"
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn(d, title = "Erdos-Rényi, p = 100, n = 200")


ggplot2::ggsave(
  "weight-matrix-random-p100-n200.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)


d <- data %>% filter(
  p == 100, 
  n_obs == 200, 
  density == 0.1, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "scale-free", 
  score == "OracleF1"
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn(d, title = "Scale-free, p = 100, n = 200")


ggplot2::ggsave(
  "weight-matrix-scale-free-p100-n200.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)


d <- data %>% filter(
  p == 200, 
  n_obs == 100, 
  density == 0.05, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "random", 
  score == "OracleF1"
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn(d, title = "Erdos-Rényi, p = 200, n = 100")


ggplot2::ggsave(
  "weight-matrix-random-p200-n100.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)


d <- data %>% filter(
  p == 200, 
  n_obs == 100, 
  density == 0.05, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "scale-free", 
  score == "OracleF1"
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn(d, title = "Scale-free, p = 200, n = 100")

ggplot2::ggsave(
  "weight-matrix-scale-free-p200-n100.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)




#######################

data$score <- as.character(data$score)
data$score[data$score == 'OracleF1'] <- 'Best F1-score'
data$score <- as.factor(data$score)#, c("AIC", "BIC", "Best F1-score"))


d <- data %>% filter(
  p == 200, 
  n_obs == 100, 
  density == 0.05, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "scale-free", 
  type_weight_matrix == "grid"
)



boxplot_cvn2 <- function(d, title = "") {
  ggplot(d, aes(x = factor(score, level = c("AIC", "BIC", "Best F1-score")) , y = F1, color = score)) + 
    geom_boxplot() + 
    xlab("selection criterion") + 
    ggtitle(title) + 
    ylab("F1 score") + 
    ylim(0, .83) +
    scale_color_brewer(palette="Dark2") + 
    theme_bw() + 
    theme(legend.position = "none")  
}

boxplot_cvn2(d)








d <- data %>% filter(
  p == 100, 
  n_obs == 200, 
  density == 0.1, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "random", 
  type_weight_matrix == "grid"
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn2(d, title = "Erdos-Rényi, p = 100, n = 200")

ggplot2::ggsave(
  "criterion-random-p100-n200.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)

d <- data %>% filter(
  p == 100, 
  n_obs == 200, 
  density == 0.1, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "scale-free", 
  type_weight_matrix == "grid"
)

ggplot2::ggsave(
  "criterion-scale-free-p100-n200.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn2(d, title = "Scale-free, p = 100, n = 200")

d <- data %>% filter(
  p == 200, 
  n_obs == 100, 
  density == 0.05, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "random", 
  type_weight_matrix == "grid"
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn2(d, title = "Erdos-Rényi, p = 200, n = 100")

ggplot2::ggsave(
  "criterion-random-p200-n100.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)

d <- data %>% filter(
  p == 200, 
  n_obs == 100, 
  density == 0.05, 
  percentage_edges_x == 0.1, 
  percentage_edges_y == 0.1, 
  type == "scale-free", 
  type_weight_matrix == "grid"
)

min(d$F1)
max(d$F1)

p <- boxplot_cvn2(d, title = "Scale-free, p = 200, n = 100")

ggplot2::ggsave(
  "criterion-scale-free-p200-n100.png",
  p,
  scale = 1,
  width = 4,
  height = 4,
  dpi = 300
)






source("parameter-settings.R")

sim_param
algo_param
settings <- merge(sim_param, algo_param)

get_subset <- function(data, row_settings) { 
  data %>% filter(
    sim_param_id == row_settings$sim_param_id, 
    type_weight_matrix == row_settings$type_weight_matrix
  )
}

b = get_subset(data, settings[1,])

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

for (i in 1:nrow(settings)) { 
  row_settings <- settings[i, ]
  
  p <- create_boxplot(data, row_settings, var = "F1")  
  
  filename <- paste0(lapply(as.list(row_settings), function(x) as.character(x)), collapse = "_")
  
  filename <- paste0("figures/", filename, collapse = "")
  
  filename <- paste0(filename, ".pdf", collapse = "")
  
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

