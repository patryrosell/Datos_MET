# Script for sorting and saving data

guarda_norm<-function(TP_completo,equi,file_YYYY,overwrite){
  
  # Check if output folder exists
  if (!dir.exists(file_YYYY)){
  
    dir.create(file_YYYY)
	
  }
  
  # Search for identification of the station
  OMM=as.character(equi$OMM)
  OACI=as.character(equi$OACI)

  # Output file name
  file_save=paste0(file_YYYY,"/",OMM,"_",OACI,".txt")
  
  # Sort by ascending date
  TP_completo = TP_completo[order(as.POSIXct(TP_completo$DATE,format="%Y-%m-%d %H:%M:%S")),]
  
  # Sort columns for keeping output format
  TP_completo = TP_completo %>% select('DATE','PRE_stat','PRE_mar','TEMP','HUM','PREC')
  
  # We check if the file for that station already exists. If true, we add the new data to the existent.
  ## If false, we save as a new file
  if (file.exists(file_save)==FALSE){
    
    write.table(TP_completo,file_save,quote = FALSE, na="NA",dec=".",sep=",",
                row.names = FALSE,col.names = FALSE)
				
  } else {
    
    acum=read_csv(file_save, col_names = FALSE,show_col_types = FALSE)
    colnames(acum)=c("DATE","PRE_stat","PRE_mar","TEMP","HUM","PREC")
    
    # Check for overwriting. If true, we remove old data and replace it for the new ones.
    if (overwrite == "Y" ){
      
      acum_sin=anti_join(acum,TP_completo,by="DATE")
      
    } 
    
    mergi=rbind(acum_sin,TP_completo)
    mergi=mergi[!duplicated(mergi$DATE), ]
    
    write.table(mergi,file_save,quote = FALSE, na="NA",dec=".",sep=",",
                row.names = FALSE,col.names = FALSE)
				
  }
  
}