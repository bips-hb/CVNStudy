#' Installation of the packages 'CVN' and 'CVNSim', currently only available 
#' on GitHub. These packages provide the algorithm for the Covariate Varying Network
#' Model (CVN) and a simulator for CVN-type data (CVNSim). 
#' 
#' To install, use the 'devtools::install_github()' function with the GitHub 
#' repository URLs.

devtools::install_github("bips-hb/CVN")    
devtools::install_github("bips-hb/CVNSim") 

#' Additionally, the 'simtracker' package is installed, which is a library for 
#' running parallel simulations on the BIPS workstation. It also works on local 
#' machines.

devtools::install_github("bips-hb/simtracker") 
