#' Creates different weight matrices
#' 
#' @param type The type of weight matrix
#' @param m Number of graphs
#' 
#' @return Weight matrix
create_weight_matrix <- function(type = c("full", "glasso", "grid", "uniform-random"), m = 9) { 
   
  # check correctness input
  if (!type[1] %in% c("full", "glasso", "grid", "uniform-random")) {
    stop("type unknown") 
  }
  
  switch(type[1], 
    "full"   = {W <- matrix(1, nrow = m, ncol = m)},
    "glasso" = {W <- matrix(0, nrow = m, ncol = m)},
    "grid"   = {
      if (m != 9) { 
        stop("m must be 9 to create weight matrix representing a grid")  
      }
      W <- matrix(0, nrow = m, ncol = m)
      pairs <- list(
        c(1,2), 
        c(2,3), 
        c(1,4), 
        c(2,5), 
        c(3,6), 
        c(4,5), 
        c(5,6), 
        c(4,7), 
        c(5,8),
        c(6,9),
        c(7,8),
        c(8,9)
      )
      lapply(pairs, function(e) {W[e[1], e[2]] <<- 1; W[e[2], e[1]] <<- 1})
    }, 
    "uniform-random" = {
      W <- matrix(runif(m*m), ncol = m)
      W <- W %*% t(W)
      W <- W / max(W)
      diag(W) <- 0
    }
  ) 
  
  diag(W) <- 0 
  return(W)
}
