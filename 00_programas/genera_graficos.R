# Script for plotting the accumulated values of each station.
# This script runs independently of the other programs that call it

genera_grafico <- function (path_param, dato_norm, save_graph, path_program) {
  
  packages <-
    c(
      "readr",
      "ggplot2",
      "ggthemes",
      "reshape2",
      "stringr",
      "dplyr",
      "lubridate",
      "rlang"
    )
  
  source(paste0(path_program, "/search_and_load.R"))
  source(paste0(path_program, "/acumulado.R"))
  
  search_and_load(packages)
  
  # Read parameters
  parametros = read_delim(
    path_param,
    skip = 4,
    skip_empty_rows = TRUE,
    col_names = c("Par", "valor"),
    col_types = cols(),
    comment = "#",
    delim = "=",
    progress = FALSE
  )
  
  sd_outliers = as.numeric(parametros[which(parametros$Par == "sd_outliers"), 2])
  
  source(paste0(path_program, "/outliers.R"))
  
  # List of stations
  full_names_data = list.files(dato_norm, recursive = TRUE)
  
  years_data = list.files(dato_norm, recursive = FALSE)
  
  log = list.files(dato_norm, pattern = "log", full.names = TRUE)
  
  if (is_empty(log) == FALSE) {
    # Remove name of log, if exists
    
    full_names_data = full_names_data[-length(full_names_data)]
    years_data = years_data[-length(years_data)]
    
  }
  
  # Retain only the OMM and OACI numbers
  names_data = str_sub(full_names_data, 6)
  
  names = unique(gsub(".txt", "", names_data))
  
  for (i in 1:length(names)) {
    
    name = names[i]
    
    print("***")
    print(paste0(name, " - ", i, " de ", length(names)))
    print("***")
    
    acumulado(min(years_data), max(years_data), dato_norm, names_data[i]) -> OUT2
    
    if (is.null(OUT2) == FALSE) { # check if we have data
      
      # Remove outliers only in Pressure and temperature
      for (k in 2:4) {
        var = colnames(OUT2)[k]
        remove_outliers(OUT2, var, sd_outliers) -> datos_filt
        
        if (nrow(datos_filt) != 0) {
          # check again for some data
          
          OUT2 = datos_filt
          
        }  else {
          OUT2 = NULL
          break # if there's nothing there, we leave
          
        }
        
      } # enf for
      
    } # end if.null
    
    if (is.null(OUT2) == FALSE) {
      # With data we plot, without, bye
      
      datos = melt(OUT2, na.rm = FALSE, id = "DATE")
      
      (
      ps = ggplot(data = datos, aes( x = DATE, y = value)) + 
        geom_point(aes(colour = variable), 
                   alpha = 0.2,
                   position = position_jitter(width = NULL, height = 0.05)
                   ) +
        theme_calc() +
        labs(x = "Date", y = "Variable") +
        ggtitle(paste0("Meteorological data for: ", name)) +
        facet_wrap(~ variable,
                   ncol = 3,
                   scales = "free_y",
                   labeller = as_labeller(c(PRE_stat = "Pressure at station level [hPa]", 
                                             PRE_mar = "Pressure at sea level [hPa]", 
                                             TEMP = "Temperature [ºC]",
                                             HUM = "Humidity [%]",
                                             PREC = "Precipitation [mm]")) 
                   ) + 
        guides(colour = FALSE) +
        geom_smooth(colour = "black")
      )
      
      ps_name = paste0(save_graph, "/", name, ".jpeg")
      
      ggsave(ps_name,
             plot = ps,
             dpi = 300,
             width = 30,
             height = 15,
             units = "cm"
             )
      
    } else {
      print("No data for plotting")
      
    }
    
  } # End loop for each station
  
  print("---")
  print("Plotting has ended")
  
}

genera_grafico(path_param, dato_norm, save_graph, path_program)
