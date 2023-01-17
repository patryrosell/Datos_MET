genera_norm_smn<-function(){
  # La finalidad de este script es leer tanto los datos de tiempo presente como los horarios, 
  ## para la generación de un único archivo de datos con formato normalizado. El script toma la 
  ## fecha más antigua de ambos listados y controla la existencia de ambos archivos. 
  ## Si existe únicamente los datos de tiempo presente, se complentan los datos con la información
  ## allí presente.
  ## Si existe únicamente los datos horarios, se completa con la información allí presente. 
  ## Si existen ambos archivos, se completa con la información de ambos listados.
  
  packages <- c("readr", "dplyr", "stringr","lubridate","readxl","data.table","padr","gdata")
   check.and.install.Package<-function(package_name){
     if(!package_name%in%installed.packages()){
       install.packages(package_name)
     }
   }
   
   check.and.install.Package("readr")
   check.and.install.Package("dplyr")
   check.and.install.Package("stringr")
   check.and.install.Package("lubridate")
   check.and.install.Package("readxl")
   check.and.install.Package("data.table")
   check.and.install.Package("padr")
   check.and.install.Package("gdata")
  
   suppressPackageStartupMessages({
     library(readr) # Para cargar las tablas 
     library(dplyr) # Manipulación de datos
     library(stringr)
     library(lubridate)
     library(readxl)
     library(data.table)
     library(padr)
     library(gdata)
   })
  
  path_param="/nfs/gps2/sd0/proyectos/Datos_MET/parametros.txt"
  
  # Leo parámetros
  parametros=read_delim(path_param,
                        skip=4,
                        skip_empty_rows = TRUE,
                        col_names = c("Par","valor"),
                        col_types = cols(),
                        delim="=",progress = FALSE)
  
  # Cargo funciones importantes para filtrado y guardado
  smn_prog=as.character(parametros[which(parametros$Par == "smn_programas"),2])
  
  source(paste0(smn_prog,"/busca_TP_smn.R"))
  source(paste0(smn_prog,"/busca_DH_smn.R"))
  source(paste0(smn_prog,"/guarda_norm_smn.R"))
  source(paste0(smn_prog,"/busca_stat.R"))
  
  # Busco listado de datos crudos
  smn_datohorario_row=as.character(parametros[which(parametros$Par == "smn_datohorario_row"),2])
  
  smn_datoTP_row=as.character(parametros[which(parametros$Par == "smn_datoTP_row"),2])
  
  SMN_row=as.character(parametros[which(parametros$Par == "SMN"),2])
  
  equal=as.character(parametros[which(parametros$Par == "smn_equivalencias"),2])
  
  smn_dato_norm=as.character(parametros[which(parametros$Par == "smn_dato_norm"),2])
  
  overwrite=as.character(parametros[which(parametros$Par == "overwrite"),2])
  
  # Cargo lista de estaciones con sus equivalencias
  
  equivalencias=read_excel(equal,sheet="equivalencias")
  
  # Listo los archivos de cada uno
  
  TP=list.files(smn_datoTP_row,pattern = "tiepre",full.names = TRUE)
  
  hor=list.files(smn_datohorario_row,pattern = "datohorario", recursive = TRUE, full.names = TRUE)
  
  # Genero listado de fechas. Para eso, me quedo con los caracteres que contienen la fecha
  ## elimino errores y los transformo a formato fecha.
  
  TP_dates=as.Date(str_sub(TP,-12,-5),format="%Y%m%d")
  TP_dates=TP_dates[!is.na(TP_dates)]
  
  hor_dates=as.Date(str_sub(hor,-12,-5),format="%Y%m%d")
  hor_dates=hor_dates[!is.na(hor_dates)]
  
  # Generamos un log para que guarde la última fecha que se analizó
  ## y siempre retome desde ahí
  log_smn=paste0(smn_dato_norm,"/log_smn")
  
  if (file.exists(log_smn) == TRUE) {
    log=read_csv(log_smn,col_names = FALSE,show_col_types = FALSE)
    log=log[[1]]
    old=as.Date(log,format="%Y-%m-%d")
  } else {
    
    old=min(append(TP_dates,hor_dates))
  }
  
  today=lubridate::ymd(format(Sys.Date(), "%Y%m%d"))
  
  seq_days=seq(as.Date(old,format="%Y-%m-%d"), as.Date(today,format="%Y%m%d"), by="days")
  
  seq_years=seq(as.Date(old,format="%Y-%m-%d"), as.Date(today,format="%Y%m%d"), by="years")
  
  # inicio un for para tener los datos separados por año
  
  for (ii in (year(old):year(today))){
    
    # Controlamos que exista la carpeta del año donde se guardaran los datos
    file_YYYY=paste0(smn_dato_norm,"/",as.character(ii))
    
    # Ahora que nos aseguramos que la carpeta existe, seguimos leyendo datos
    # Filtro la secuencia de dias para tener los datos sólo del año que interesa
    YYYY=as.character(ii)
    print(YYYY)
    
    seq_days_YYYY=str_subset(seq_days,pattern = YYYY)
    dias=length(seq_days_YYYY)
    
    for (i in(1:dias)){
      
      FECHA=seq_days_YYYY[i]
      
      print(FECHA)
      
      # Genero los nombres de los archivos que debo leer
      YYYY=lubridate::year(FECHA)
      MM=sprintf("%02d", lubridate::month(FECHA))
      DD=sprintf("%02d", lubridate::day(FECHA))
      date=paste0(YYYY,MM,DD)
      
      arc_TP=paste0(smn_datoTP_row,"/tiepre",date,".txt")
      
      arc_hor=paste0(smn_datohorario_row,"/",YYYY,"/datohorario",date,".txt")
      
      # si existen los archivos, los leo, sino lo informo
      
      # BUSCO DATO TIEMPO PRESENTE

      if(file.exists(arc_TP) == TRUE){
        
        flag_TP=1
        datos_fin<-busca_TP_smn(arc_TP)
        
      } else {
        flag_TP=0
        #print(paste0("No existe dato de tiempo presente"))
        datos_fin=NULL
      } # Fin for dato tiempo presente
      
      # BUSCO DATO HORARIO
      
      if(file.exists(arc_hor) == TRUE){
        
        flag_DH=1
        datos_ord<-busca_DH_smn(arc_hor)
        
      } else {
        flag_DH=0
        #print(paste0("No existe archivo de dato horario"))
        datos_ord=NULL
      } # Fin for dato horario
      
      # Ahora que tengo todos los datos de ese día leídos, puedo hacer otro for
      ## donde voy a filtrar por cada una de las estaciones del listado normalizado
      if (flag_TP == 1 & flag_DH == 1) {
        
        #print("1 1")
        
        # Si ambos archivos existen, filtramos los dos que ya se leyeron antes y los unimos  
        for (j in (1:nrow(equivalencias))){
          
          # # Busco los datos de la estación
          # OMM=as.character(equivalencias$OMM[j])
          # OACI=as.character(equivalencias$OACI[j])
          # 
          # # Busco estación del listado "stat_TP" (porque estoy en Tiempo Presente)
          # stat_TP=as.character(equivalencias$stats_TP[j])
          # 
          # # Busco nombres posibles para la estaciñon, en el del listado "stat_DH" 
          # ## (porque estoy en Dato Horario)
          # stat_DH=as.character(equivalencias$stats_DH[j])
          # stat_DH2=as.character(equivalencias$stats_DH2[j])
          # stat_DH3=as.character(equivalencias$stats_DH3[j])
          # 
          # # filtro dato tiempo presente
          # datote=dplyr::filter(datos_fin,NAME == stat_TP)
          # datote$PREC=NA # Para futuros valores de precipitaciones
          # datote=datote[,-1]
          # 
          # # filtro dato horario
          # datote2=dplyr::filter(datos_ord,NAME == stat_DH)
          # 
          # # Si no encuentra datos con un nombre, busca con el otro
          # if (nrow(datote2) == 0){
          #   datote2=dplyr::filter(datos_ord,NAME == stat_DH2)
          # }
          # 
          # if (nrow(datote2) == 0){
          #   datote2=dplyr::filter(datos_ord,NAME == stat_DH3)
          # }
          datote<-busca_stat(j,equivalencias,datos_fin) #Dato tiempo presente
          datote2<-busca_stat(j,equivalencias,datos_ord) #Dato horario
          
          if (!nrow(datote2) == 0 & !nrow(datote) == 0) {
            # datote2=datote2[,-1]
            # datote2$PREC=NA # Para futuros valores de precipitaciones
            
            # Unifico los dos dataframes. Acá sólo pego las columas de PRE_mar a los datos
            ## de tiempo presente.
            TP_comp=merge(x = datote, y = datote2[,c(1,2)], by = "DATE", all.x = TRUE)
            
            # Ahora agrego las columnas que faltan de acuerdo a las fechas faltantes
            TP_completo=rows_upsert(TP_comp,datote2,by="DATE")
            
            # Ordeno los datos para que queden como queremos
            TP_completo=TP_completo[,c('DATE','PRE_stat','PRE_mar','TEMP','HUM','PREC')]
            
            # Ordeno por fecha ascendente
            #TP_completo = TP_completo[order(as.POSIXct(TP_completo$DATE,format="%d %B %Y %H:%M:%S")),]
            
            # Guardo llamando a la función guardar
            guarda_norm(TP_completo,equivalencias,j,file_YYYY,overwrite)            
          } else if (nrow(datote2) == 0 & !nrow(datote) == 0){
            # Puede pasar que al filtrar por estación, aún tengamos una sin datos por alguna falla
            datote$PRE_mar=NA
            TP_completo=datote[,c('DATE','PRE_stat','PRE_mar','TEMP','HUM','PREC')]
            guarda_norm(TP_completo,equivalencias,j,file_YYYY,overwrite)
          } else if (!nrow(datote2) == 0 & nrow(datote) == 0){
            # Puede pasar que al filtrar por estación, aún tengamos una sin datos por alguna falla
            datote2$PRE_stat=NA
            TP_completo=datote2[,c('DATE','PRE_stat','PRE_mar','TEMP','HUM','PREC')]
            guarda_norm(TP_completo,equivalencias,j,file_YYYY,overwrite)
          } else {
              TP_completo=NULL
          }
          
        } # Fin if por el control de la existencia de los dos archivos
        
      } else if (flag_TP == 1 & flag_DH == 0) {
        
        #print("1 0")
        # Ahroa lidiamos con la existencia unica de los datos de TP
        for (j in (1:nrow(equivalencias))){
          
          # # Busco los datos de la estación
          # OMM=as.character(equivalencias[j,1][[1]])
          # OACI=equivalencias[j,2][[1]]
          # 
          # # Busco primera estación del listado "stat_TP" (porque estoy en Tiempo Presente)
          # stat_TP=equivalencias[j,4][[1]]
          
          # filtro dato tiempo presente
          # datote=dplyr::filter(datos_fin,NAME == stat_TP)
          
          datote<-busca_stat(j,equivalencias,datos_fin)
          
          if (!nrow(datote) == 0){
            # datote$PREC=NA # Para futuros valores de precipitaciones
            datote$PRE_mar=NA
            #datote=datote[,-1]
            
            # Ordeno los datos para que queden como queremos
            TP_completo=datote[,c('DATE','PRE_stat','PRE_mar','TEMP','HUM','PREC')]
            
            # Ordeno por fecha ascendente
            #TP_completo = TP_completo[order(as.POSIXct(TP_completo$DATE,format="%d %B %Y %H:%M:%S")),]
            
            # Guardo llamando a la función guardar
            guarda_norm(TP_completo,equivalencias,j,file_YYYY,overwrite)  
          } else {
            TP_completo=NULL
          }

        } # Fin if por el control de la existencia de dato TP
        
      } else if (flag_TP == 0 & flag_DH == 1) {
        
        #print("0 1")
        # Ahroa lidiamos con la existencia unica de los datos horarios
        for (j in (1:nrow(equivalencias))){
          #print(j)
          
          # Busco los datos de la estación
          # OMM=as.character(equivalencias[j,1][[1]])
          # OACI=equivalencias[j,2][[1]]
          # 
          # # Busco nombres posibles para la estaciñon, en el del listado "stat_DH" 
          # ## (porque estoy en Dato Horario)
          # stat_DH=equivalencias[j,5][[1]]
          # stat_DH2=equivalencias[j,6][[1]]
          # stat_DH3=equivalencias[j,7][[1]]
          # 
          # # filtro dato horario
          # datote2=dplyr::filter(datos_ord,NAME == stat_DH)
          # 
          # # Si no encuentra datos con un nombre, busca con el otro
          # if (nrow(datote2) == 0){
          #   datote2=dplyr::filter(datos_ord,NAME == stat_DH2)
          # }
          # 
          # if (nrow(datote2) == 0){
          #   datote2=dplyr::filter(datos_ord,NAME == stat_DH3)
          # }
          
          datote2<-busca_stat(j,equivalencias,datos_ord)
          
          # Controlo que después del fitro, me haya quedado con datos
          if (!nrow(datote2) == 0 ){
            #datote2=datote2[,-1]
            # datote2$PREC=NA # Para futuros valores de precipitaciones
            datote2$PRE_stat=NA
            
            # Ordeno los datos para que queden como queremos
            TP_completo=datote2[,c('DATE','PRE_stat','PRE_mar','TEMP','HUM','PREC')]
            
            # Ordeno por fecha ascendente
            #TP_completo = TP_completo[order(as.POSIXct(TP_completo$DATE,format="%d %B %Y %H:%M:%S")),]
            
            # Guardo llamando a la función guardar
            guarda_norm(TP_completo,equivalencias,j,file_YYYY,overwrite)
          } else {
            TP_completo=NULL
          }

        } # Fin if por el control de la existencia de datos horarios
        
      } else {
        print("No existe ningún archivo de datos para la fecha indicada")
        TP_completo=NULL
      }
      
      # Generamos un log para que guarde la última fecha que se analizó
      ## y siempre retome desde ahí
      write.table(FECHA,log_smn,quote = FALSE, na="NA",row.names = FALSE,col.names = FALSE)
      
    } # Fin for por día de ese año
    
  } # fin for por año
  
  print("La normalización de datos del SMN (horarios y tiempo presente), ha finalizado")

}

genera_norm_smn()
