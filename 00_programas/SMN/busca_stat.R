busca_stat <- function(equi, datos) {
  
  names = unlist(c(equi[-(1:5)]), use.names = FALSE) # Remove first 5 col. I don't want that info
  
  filtro = dplyr::filter(datos, NAME %in% names)
  
  if (!nrow(filtro) == 0) {
    filtro$PREC = NA # Add empty values of precipitation
    
    filtro = filtro[,-1] # Remove station name
    
    filtro = filtro[!duplicated(filtro$DATE), ] # Remove duplicated dates
    
  }
  
  filtro
  
}