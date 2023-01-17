busca_DH_smn <- function(arc_hor) {
  # Leo por ancho de columnas (es mas facil, solo hay que rogar que los del SMN no cambien
  # el formato de los datos)
  datos = read.fwf(
    arc_hor,
    widths = c(8, 6, 6, 5, 8, 5, 7, 36),
    skip = 2,
    fileEncoding = "ISO-8859-1"
  )
  
  # Nombro las columnas
  colnames(datos) <-
    c("FECHA", "HORA", "TEMP", "HUM", "PRE_mar", "DD", "FF", "NAME")
  
  # Unifico las columas con la fecha y hora
  datos$DATE = paste0(as.character(sprintf("%08d", datos$FECHA)), " ", datos$HORA)
  datos$DATE = as.POSIXct(datos$DATE, format = "%d%m%Y %H", tz = "America/Argentina/Buenos_Aires")
  
  # Paso hora local a UTC
  datos$DATE = with_tz(ymd_hms(datos$DATE, tz = "America/Argentina/Buenos_Aires"),
                       "GMT")
  
  # Ordeno los datos y me quedo solo con los que me interesan
  datos_ord = datos[, c(8, 9, 5, 3, 4)]
  
  # Elimino los espacios que estan antes y despues de todo lo que esta considerado como text
  ## excepto los espacios entre medio de los nombres de los lugares.
  
  datos_ord$NAME = trimws(datos_ord$NAME, which = c("both"))
  
  datos_ord
  
}