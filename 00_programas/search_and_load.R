search_and_load <- function(pack) {
  
  for (p in pack) {
    
    if (!require(p, character.only = TRUE))
      install.packages(p)
    
    suppressPackageStartupMessages({
      library(p, character.only = TRUE)
    })
    
  }
  
}
