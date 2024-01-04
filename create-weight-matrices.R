#' Creates different weight matrices
#' 
#' This function generates different types of weight matrices based on the specified type.
#' 
#' @param type The type of weight matrix. Options include "full", "glasso", "grid", 
#'              and "uniform-random".
#' @param m Number of nodes or graphs (default is 9 for the "grid" type)
#' 
#' @return Weight matrix of specified type
create_weight_matrix <- function(type = c("full", "glasso", "grid", "uniform-random"), m = 9) { 
  
  # Check if the specified type is valid
  if (!type[1] %in% c("full", "glasso", "grid", "uniform-random")) {
    stop("type unknown") 
  }
  
  # Generate weight matrix based on the specified type
  switch(type[1], 
         "full"   = {W <- matrix(1, nrow = m, ncol = m)},       # Full connectivity matrix
         "glasso" = {W <- matrix(0, nrow = m, ncol = m)},       # Graphical LASSO sparse matrix
         "grid"   = {
           # Check if m is 9 for creating a grid matrix
           if (m != 9) { 
             stop("m must be 9 to create weight matrix representing a grid")  
           }
           
           # Create grid connectivity matrix
           W <- matrix(0, nrow = m, ncol = m)
           pairs <- list(
             c(1,2), c(2,3), c(1,4), c(2,5), c(3,6),    # Define pairs of connected nodes for a grid
             c(4,5), c(5,6), c(4,7), c(5,8), c(6,9),
             c(7,8), c(8,9)
           )
           lapply(pairs, function(e) {W[e[1], e[2]] <<- 1; W[e[2], e[1]] <<- 1})  # Set grid connections
         }, 
         "uniform-random" = {
           # Generate a random symmetric matrix with uniform values
           W <- matrix(runif(m*m), ncol = m)
           W <- W %*% t(W)
           W <- W / max(W)
           diag(W) <- 0   # Set diagonal elements to 0
         }
  ) 
  
  # Set diagonal elements to 0 (if not already set)
  diag(W) <- 0 
  
  return(W) # Return the generated weight matrix
}