busca_stat<-function(j,equivalencias,datos){
  
  # 
  # # Busco los datos de la estación
  # OMM=as.character(equivalencias$OMM[j])
  # OACI=as.character(equivalencias$OACI[j])
  # 
  # Busco estación del listado "stat_TP" (porque estoy en Tiempo Presente)
  stat_TP=as.character(equivalencias$stats_TP[j])
  
  # Busco nombres posibles para la estaciñon, en el del listado "stat_DH" 
  ## (porque estoy en Dato Horario)
  stat_DH=as.character(equivalencias$stats_DH[j])
  stat_DH2=as.character(equivalencias$stats_DH2[j])
  stat_DH3=as.character(equivalencias$stats_DH3[j])
  
  # filtro nombre tiempo presente
  filtro=dplyr::filter(datos,NAME == stat_TP)
  
  # filtro nombre dato horario 1
  if (nrow(filtro) == 0){
  filtro=dplyr::filter(datos,NAME == stat_DH)
  }
  
  # Si no encuentra datos con un nombre, filtro nombre dato horario 2
  if (nrow(filtro) == 0){
    filtro=dplyr::filter(datos,NAME == stat_DH2)
  }
  
  # Si no encuentra datos con un nombre, filtro nombre dato horario 3
  if (nrow(filtro) == 0){
    filtro=dplyr::filter(datos,NAME == stat_DH3)
  }
  
  if (!nrow(filtro) == 0){
    filtro$PREC=NA # Agrego columna para futuros valores de precipitación
    
    filtro=filtro[,-1] # Elimino columna con el nombre de la estación
    
    filtro=filtro[!duplicated(filtro$DATE), ]
  }
  
  filtro
  
}