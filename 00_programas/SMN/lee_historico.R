lee_historico <- function(path_param, path_program) {
  # Este programa lee los datos historicos del documento comprado al SMN
  ## datos estaciones meteorologicas 2015-2016.xlsx
  
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
  
  # Leo el listado de estaciones son sus equivalencias
  equal = as.character(parametros[which(parametros$Par == "smn_equivalencias"), 2])
  
  smn_historico = as.character(parametros[which(parametros$Par == "smn_historico"), 2])
  
  smn_dato_norm = as.character(parametros[which(parametros$Par == "smn_dato_norm"), 2])
  
  smn_prog = as.character(parametros[which(parametros$Par == "smn_programas"), 2])
  
  overwrite = as.character(parametros[which(parametros$Par == "overwrite"), 2])
  
  # Cargo funciones importantes para filtrado y guardado
  source(paste0(smn_prog, "/guarda_norm_smn.R"))
  
  # Leo el archivo de datos historicos y listado de estaciones
  equivalencias = read_excel(equal, sheet = "equivalencias")
  
  historico = read_excel(
    smn_historico,
    sheet = "DATOS",
    skip = 25,
    col_names = TRUE
  )
  
  hist = historico %>% select("A", "B", "C", "D", "K", "L", "V")
  
  hist$DATE = paste0(as.character(hist$B), " ", as.character(hist$C))
  
  # genero listado de las estaciones presentes dentro del archivo
  stats = unique(hist$A)
  
  # Y ahora hago un for, para filtrar por cada estacion y agregarla a lo que
  ## ya existe
  
  for (i in 1:length(stats)) {
    print(' ')
    print(' ********** ')
    print(stats[i])
    
    # Busco la equivalencia del nombre de la estacion
    fila = dplyr::filter(equivalencias, OMM == stats[i])

    hist_stat = dplyr::filter(hist, A == stats[i])
    
    # controlo que los filtros me den algo con datos y no sea solo un error
    if (nrow(hist_stat) != 0) {
      # agrego columna para humedad y luego ordeno filas
      hist_stat$HUM = NA
      hist_stat = hist_stat %>% select("DATE", "K", "L", "D", "HUM", "V")
      
      # renombro filas para no perderme a futuro
      colnames(hist_stat) <- c("DATE", "PRE_stat", "PRE_mar", "TEMP", "HUM", "PREC")
      
      # transformo a formato fecha la columna DATE
      hist_stat$DATE = as.character(hist_stat$DATE)
      
      hist_stat$DATE = as.POSIXct(hist_stat$DATE, format = "%Y-%m-%d %H", tz = "UTC")
      
      # Ahora hago otro for para que me separe los datos por año
      anios = unique(year(hist_stat$DATE))
      
      for (j in 1:length(anios)) {
        print(anios[j])
        
        # Filtro por anio
        hist_anio = dplyr::filter(hist_stat, year(DATE) == anios[j])
        # Genero nombre del archivo que quiero
        file_YYYY = paste0(smn_dato_norm, "/", anios[j])
        
        # Llamo funcion para guardar datos
        guarda_norm(hist_anio, fila, file_YYYY, overwrite)
      } # fin for por anio
      
    } else {
      print(paste0("No data for station ", stats[i]))
    } # fin if control datos
    
  } # fin for por estacion
  
  print("*** Formatting historical records have ended")
  
}
