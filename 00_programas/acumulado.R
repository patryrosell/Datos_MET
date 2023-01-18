acumulado<- function (min_y,max_y,dato_norm,name){
  
  OUT = NULL
  
  for (j in min_y:max_y) {
    file = (paste0(dato_norm, "/", j, "/", name))
    
    if (file.exists(file) == TRUE) {
      dati = read_csv(
        file,
        col_names = c("DATE", "PRE_stat", "PRE_mar", "TEMP", "HUM", "PREC"),
        show_col_types = FALSE
      )
      
      dati$DATE = as.POSIXct(dati$DATE, format = "%Y-%m-%d %H:%M:%S", tz =
                               "UTC")
      
      OUT = rbind(OUT, dati)
    }
    
  } # end merging data
  
  OUT
  
}


