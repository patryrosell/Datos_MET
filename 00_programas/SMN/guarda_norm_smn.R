# Genero una función para guardar los datos y no tener que replicar esto mil veces

guarda_norm<-function(TP_completo,equivalencias,j,file_YYYY,overwrite){
  
  # Controlo que el directorio por año exista, sino lo genero
  if (!dir.exists(file_YYYY)){
    dir.create(file_YYYY)
  }
  
  # # Busco los datos de la estación
  OMM=as.character(equivalencias$OMM[j])
  OACI=as.character(equivalencias$OACI[j])

  # Genero el nombre de salida del archivo. En caso de no tener uno de los dos
  ## valores (OMM u OACI), se colocaría un NA. En cao de no quererlo, incorporar
  ## un IF para que arme otro nombre de acuerdo a la disponibilidad de los datos
  file_save=paste0(file_YYYY,"/",OMM,"_",OACI,".txt")
  
  # Antes que nada, es imporante controlar que el archivo exista para esa estación.
  ## Si existe, tiene que leerlo y agregar los datos nuevos. Si no existe, lo tiene 
  ## que guardar.
  
  # Ordeno por fecha ascendente
  TP_completo = TP_completo[order(as.POSIXct(TP_completo$DATE,format="%Y-%m-%d %H:%M:%S")),]
  
  # Filtro por outliers
  
  
  if (file.exists(file_save)==FALSE){
    
    write.table(TP_completo,file_save,quote = FALSE, na="NA",dec=".",sep=",",
                row.names = FALSE,col.names = FALSE)
  } else {
    
    acum=read_csv(file_save, col_names = FALSE,show_col_types = FALSE)
    colnames(acum)=c("DATE","PRE_stat","PRE_mar","TEMP","HUM","PREC")
    
    # Acá controlo si quiero eliminar los valores viejos y reemplazarlos por nuevos
    if (overwrite == "Y" ){
      
      acum_sin=anti_join(acum,TP_completo,by="DATE")
      
    } 
    
    mergi=rbind(acum_sin,TP_completo)
    mergi=mergi[!duplicated(mergi$DATE), ]
    
    # Ordeno por fecha ascendente
    mergi = mergi[order(as.POSIXct(mergi$DATE,format="%Y-%m-%d %H:%M:%S")),]
    
    write.table(mergi,file_save,quote = FALSE, na="NA",dec=".",sep=",",
                row.names = FALSE,col.names = FALSE)
  }
  
  #print(paste0(".... Guardado en ",file_save))
  
}

#guarda_norm()
