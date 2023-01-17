busca_DH_smn<-function(arc_hor){
  
  # Leo por ancho de columnas (es más fácil, sólo hay que rogar que los del SMN no cambien
  # el formato de los datos)
  datos=read.fwf(arc_hor,
                 widths=c(8,6,6,5,8,5,7,36),skip=2,fileEncoding="ISO-8859-1")
  
  # Nombro las columnas
  colnames(datos)<-c("FECHA","HORA","TEMP","HUM","PRE_mar","DD","FF","NAME")

  # Unifico las columas con la fecha y hora
  datos$DATE=paste0(as.character(sprintf("%08d",datos$FECHA))," ",datos$HORA)
  datos$DATE=as.POSIXct(datos$DATE,format="%d%m%Y %H",tz="America/Argentina/Buenos_Aires")
  
  # Paso hora local a UTC
  datos$DATE=with_tz(ymd_hms(datos$DATE,tz="America/Argentina/Buenos_Aires"),"GMT")
  
  # Ordeno los datos y me quedo sólo con los que me interesan
  datos_ord=datos[,c(8,9,5,3,4)]
  
  # Elimino los espacios que estan antes y después de todo lo que está considerado como text
  ## excepto los espacios entre medio de los nombres de los lugares. Idea robada de internet.
  
  datos_ord$NAME=trimws(datos_ord$NAME, which = c("both"))
  
  datos_ord
  # setDT(datos_ord)
  # cols_to_be_rectified <- names(datos_ord)[vapply(datos_ord, is.character, logical(1))]
  # datos_ord[,c(cols_to_be_rectified) := lapply(.SD, trimws), .SDcols = cols_to_be_rectified]
  # 
  # Hasta acá sólo leimos los datos, ahora queda filtrar por estación. Para eso, es necesario
  ## otro for que vaya de estación a estación, para una X cantidad de estaciones
  # stats=toupper(sort(unique(datos_ord$NAME)))
  # stats_0=iconv(stats, to='ASCII//TRANSLIT')
  # nstats=length(stats)
  
  # write.table(stats_0,paste0(SMN_row,"/aux/stats_DH.txt"),quote = FALSE, na="NA",dec=".",sep=",",row.names = FALSE,
  #             fileEncoding = "ISO-8859-1",col.names = FALSE)
}

#busca_DH_smn()