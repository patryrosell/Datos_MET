genera_norm_smn <- function(path_param,path_program) {
  # Main script for reading and cleaning data from the Servicio Meteorológico Nacional of Argentina
  ## It reads real-time data and hourly data, freely available at https://www.smn.gob.ar/descarga-de-datos
  ## and transform it into a normalized format.
  
  packages <-
    c("readr",
      "dplyr",
      "stringr",
      "lubridate",
      "readxl",
      "data.table",
      "padr",
      "gdata")
  
  source(paste0(path_program, "/search_and_load.R"))
  
  search_and_load(packages)
  
  T1=Sys.time()
  
  # Read parameters file
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
  
  smn_programas = as.character(parametros[which(parametros$Par == "smn_programas"), 2])
  
  # Loading useful functions
  source(paste0(smn_programas, "/busca_TP_smn.R"))
  source(paste0(smn_programas, "/busca_DH_smn.R"))
  source(paste0(smn_programas, "/guarda_norm_smn.R"))
  source(paste0(smn_programas, "/busca_stat.R"))
  
  # Read specific parameters
  smn_datohorario_raw = as.character(parametros[which(parametros$Par == "smn_datohorario_raw"), 2])
  
  smn_datoTP_raw = as.character(parametros[which(parametros$Par == "smn_datoTP_raw"), 2])
  
  equal = as.character(parametros[which(parametros$Par == "smn_equivalencias"), 2])
  
  smn_dato_norm = as.character(parametros[which(parametros$Par == "smn_dato_norm"), 2])
  
  overwrite = as.character(parametros[which(parametros$Par == "overwrite"), 2])
  
  graph_acum = as.character(parametros[which(parametros$Par == "graph_acum"), 2])
  
  # Load equivalences table
  
  equivalencias = read_excel(equal, sheet = "equivalencias")
  
  # list of available data
  
  TP = list.files(smn_datoTP_raw, pattern = "tiepre", full.names = TRUE)
  
  hor = list.files(
    smn_datohorario_raw,
    pattern = "datohorario",
    recursive = TRUE,
    full.names = TRUE
  )
  
  # Listing dates and transforming it into a specific format.
  
  TP_dates = as.Date(str_sub(TP, -12, -5), format = "%Y%m%d")
  TP_dates = TP_dates[!is.na(TP_dates)]
  
  hor_dates = as.Date(str_sub(hor, -12, -5), format = "%Y%m%d")
  hor_dates = hor_dates[!is.na(hor_dates)]
  
  # Creation of a log file for recording the latest date processed
  log_smn = paste0(smn_dato_norm, "/log_smn")
  
  if (file.exists(log_smn) == TRUE) {
    log = read_csv(log_smn, col_names = FALSE, show_col_types = FALSE)
    log = log[[1]]
    old = as.Date(log, format = "%Y-%m-%d")
    
  } else {
    old = min(append(TP_dates, hor_dates))
    
  }
  
  today = lubridate::ymd(format(Sys.Date(), "%Y%m%d"))
  
  seq_days = seq(as.Date(old, format = "%Y-%m-%d"),
                 as.Date(today, format = "%Y%m%d"),
                 by = "days")
  
  seq_years = seq(as.Date(old, format = "%Y-%m-%d"),
                  as.Date(today, format = "%Y%m%d"),
                  by = "years")
  
  # We want data saved by year.
  
  for (ii in (year(old):year(today))) {
    # Name of the folder for that year
    file_YYYY = paste0(smn_dato_norm, "/", as.character(ii))
    
    # Now we generate a sequence of days
    YYYY = as.character(ii)
    print(YYYY)
    
    # Sequence of dates for that year in particular
    seq_days_YYYY = str_subset(seq_days, pattern = YYYY)
    dias = length(seq_days_YYYY)
    
    # Loop for each day
    for (i in(1:dias)) {
      FECHA = seq_days_YYYY[i]
      
      print(FECHA)
      
      # Creation of filenames for searching
      YYYY = lubridate::year(FECHA)
      MM = sprintf("%02d", lubridate::month(FECHA))
      DD = sprintf("%02d", lubridate::day(FECHA))
      date = paste0(YYYY, MM, DD)
      
      arc_TP = paste0(smn_datoTP_raw, "/tiepre", date, ".txt")
      
      arc_hor = paste0(smn_datohorario_raw,
                       "/",
                       YYYY,
                       "/datohorario",
                       date,
                       ".txt")
      
      # Search real-time file
      
      if (file.exists(arc_TP) == TRUE) {
        
        if (file.info(arc_TP)$size > 50){
          flag_TP = 1
          datos_fin <- busca_TP_smn(arc_TP)
        }
        
      } else {
        flag_TP = 0
        datos_fin = NULL
        
      } # end real-time
      
      # Search hourly data
      
      if (file.exists(arc_hor) == TRUE) {
        
        if (file.info(arc_hor)$size > 50){
          flag_DH = 1
          datos_ord <- busca_DH_smn(arc_hor)
        }

      } else {
        flag_DH = 0
        datos_ord = NULL
        
      } # end hourly data
      
      for (j in (1:nrow(equivalencias))) {
        # We deal with one station at the time
        
        equi = equivalencias[j, ] # one station
        #print(paste0(equi$OMM," ",equi$OACI))
        
        if (flag_TP == 1 & flag_DH == 1) {
          # If both files exists
          
          datote <- busca_stat(equi, datos_fin) # read real-time data
          datote2 <- busca_stat(equi, datos_ord) # read hourly data
          
          if (!nrow(datote2) == 0 & !nrow(datote) == 0) {
            # Merging data frames. We only care the columns with new data
            TP_completo = full_join(datote2, datote[, c(1, 2)], by = "DATE")
            
          } else if (nrow(datote2) == 0 &
                     !nrow(datote) == 0) {
            # Check for missing station
            
            datote$PRE_mar = NA
            TP_completo = datote
            
          } else if (!nrow(datote2) == 0 &
                     nrow(datote) == 0) {
            # Check for missing station
            
            datote2$PRE_stat = NA
            TP_completo = datote2
            
          } else {
            TP_completo = NULL
            
          }
          
        } else if (flag_TP == 1 &
                   flag_DH == 0) {
          # real-time file exists, but hourly doesnt
          
          TP_completo <- busca_stat(equi, datos_fin)
          
          if (!nrow(TP_completo) == 0) {
            # Check for missing station
            
            TP_completo$PRE_mar = NA
            
          } else {
            TP_completo = NULL
            
          } # Fin if por el control de la existencia de dato TP
          
        } else if (flag_TP == 0 &
                   flag_DH == 1) {
          # Hourly data exists, but real-time doesnt
          
          TP_completo <- busca_stat(equi, datos_ord)
          
          if (!nrow(TP_completo) == 0) {
            # Check for missing station
            
            TP_completo$PRE_stat = NA
           
          } else {
            TP_completo = NULL
            
          }
          
        } else {
          TP_completo = NULL
          
        } # end if "else if"
        
        if (is.null(TP_completo) == FALSE) {
          # Save data
          
          guarda_norm(TP_completo, equi, file_YYYY, overwrite)
          
        }
        
      } # end if "equivalencias"
      
      # Log file update
      write.table(
        FECHA,
        log_smn,
        quote = FALSE,
        na = "NA",
        row.names = FALSE,
        col.names = FALSE
      )
      
    } # end loop for day
    
  } #  end loop for year
  
  T2 = Sys.time()
  
  print("----------")
  print(paste0("Elapsed time: ",difftime(T2, T1, units='mins')[[1]], " min")) # I want my own message
  print("----------")
  print(" ")
  print("Data processing has finished")
  print(" ")
  print(" ")
  
  # Plotting accumulated data if settled in the parameters file
  if (graph_acum == "Y") {
    
    print("Plotting accumulated data")
    
    source(paste0(path_program, "/genera_graficos.R"))
    
    smn_graph = as.character(parametros[which(parametros$Par == "smn_graph"), 2])
    
    genera_graficos(path_param, dato_norm, save_graph, path_program)
    
  }
  
}