genera_stats_smn<-function(){

  library(readr) # Para cargar las tablas 
  library(dplyr) # Manipulación de datos
  library(utils)
  library(data.table)
  
  path_param="/nfs/gps2/sd0/proyectos/Datos_MET/parametros.txt"
  
  # Leo parámetros
  parametros=read_delim(path_param,
                        skip=4,
                        skip_empty_rows = TRUE,
                        col_names = c("Par","valor"),
                        col_types = cols(),
                        delim="=",progress = FALSE)
  
  # Busco listado de estaciones crudas
  path_stats_row=as.character(parametros[which(parametros$Par == "smn_stats_row"),2])
  
  # Cargo datos del smn. Este .csv contiene la ubicación geográfica de todas las estaciones de la red
  smn_base<-read.fwf(path_stats_row,
                     widths=c(31,37,8,9,8,11,6,6,5),fileEncoding="ISO-8859-1")
  
  # Cambio nombre de columnas
  colnames(smn_base)=c("SITE","Provincia","Lat_g","Lat_m","Long_g","Long_m","ALT","OMM","OACI")
  
  # Elimino las dos primeras líneas con el header que quedó dando vueltas
  smn=tail(smn_base,-2)
  
  # Convierto a numeric las nuevas columnas, pues estan en character
  smn[3:7]<-lapply(smn[3:7],as.numeric,type="double") 
  
  # Elimino los espacios que estan antes y después de todo lo que está considerado como text
  ## excepto los espacios entre medio de los nombres de los lugares. Idea robada de internet.
  
  setDT(smn)
  cols_to_be_rectified <- names(smn)[vapply(smn, is.character, logical(1))]
  smn[,c(cols_to_be_rectified) := lapply(.SD, trimws), .SDcols = cols_to_be_rectified]
  
  # Genero los valores de latitud y longitud en formato decimal
  ## Uso la resta porque ya sé que todas las estaciones tienen latitud y longitud negativas
  smn$LAT=smn$Lat_g-smn$Lat_m/60
  smn$LONG=smn$Long_g-smn$Long_m/60
  
  # Elimino las 4 columas que tienen la latitud y longitud separadas en grados y minutos
  ## También elimino la columna de provincias porque no considero que sea necesaria. Principalmente
  ## porque es posible que las futura estaciones no tengan este valor. Hay que dejar únicamente
  ## los datos estrictamente necesarios, para que, si se quiere leer más de una lista a la vez, 
  ## no hayan problemas de formato.
  smn=smn[,-c(2:6)]
  
  # Ahora, organizo las columnas para que quede ordenado:
  smn=smn[,c(3,4,1,5,6,2)]
  
  # Leo en el archivo de parámetros, cuál es el nombre que le quiero dar al archivo de salida
  smn_stats_norm=as.character(parametros[which(parametros$Par == "smn_stats_norm"),2])
  
  # Guardamos:
  write.table(smn,smn_stats_norm,quote = FALSE, na="NA",dec=".",sep=",",row.names = FALSE,
              fileEncoding = "ISO-8859-1")
  
  print(paste0("Se generó un archivo de estaciones en: ",smn_stats_norm))
    
}

genera_stats_smn()
