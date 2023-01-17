busca_TP_smn <- function (arc_TP) {
  
  #Leemos datos
  datos0 = read_delim(
    arc_TP,
    delim = ";",
    locale = locale(encoding = "ISO-8859-1"),
    col_names = FALSE,
    show_col_types = FALSE
  )
  #me quedo con lo importante
  datos_filt = datos0[, c(1:3, 6, 8, 10)]
  colnames(datos_filt) <-
    c("NAME", "FECHA", "HORA", "TEMP", "HUM", "PRE_stat")
  datos_filt$PRE_stat = substr(datos_filt$PRE_stat, 1, nchar(datos_filt$PRE_stat) - 2)
  
  datos_filt[4:6] <- lapply(datos_filt[4:6], as.numeric)
  
  datos_filt$DATE = paste0(datos_filt$FECHA, " ", datos_filt$HORA)
  
  # Aca lo que hacemos es controlar si la fecha esta separada por espacios o por
  ## guiones. De acuerdo al caso, la transformacion a formato fecha se hara de una
  ## manera, o de otra.
  
  if (grepl("-", datos_filt$DATE[[1]]) == TRUE) {
    datos_filt$DATE = as.POSIXct(datos_filt$DATE,
                                 format = "%d-%B-%Y %H:%M:%S",
                                 tz = "America/Argentina/Buenos_Aires")
  } else {
    datos_filt$DATE = as.POSIXct(datos_filt$DATE,
                                 format = "%d %B %Y %H:%M:%S",
                                 tz = "America/Argentina/Buenos_Aires")
  }
  
  # Paso hora local a UTC
  datos_filt$DATE = with_tz(ymd_hms(datos_filt$DATE, tz = "America/Argentina/Buenos_Aires"),
                            "GMT")
  
  # vuelvo a ordenar y me quedo con lo que interesa:
  datos_fin = datos_filt[, c(1, 7, 6, 4, 5)]
  
  # Cambio las minusculas a mayusculas y saco las tildes
  datos_fin$NAME = toupper(datos_fin$NAME)
  datos_fin$NAME = iconv(datos_fin$NAME, to = 'ASCII//TRANSLIT')
  
  datos_fin
  
}
