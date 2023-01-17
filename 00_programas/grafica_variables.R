# Este programa permite la lectura y gráfico de alguna de las variables meteorológicas indicadas. 

# Para poder generar los gráficos, es necesario tener instaladas y cargar las 
## siguientes librerías (puede ejecutar todas estas líneas, hasta la 21 de una sola vez)

packages <- c("readr", "ggplot2", "ggthemes","readxl","reshape2")
check.and.install.Package<-function(package_name){
  if(!package_name%in%installed.packages()){
    install.packages(package_name)
  }
}

check.and.install.Package("readr")
check.and.install.Package("ggplot2")
check.and.install.Package("ggthemes")
check.and.install.Package("readxl")
check.and.install.Package("reshape2")

suppressPackageStartupMessages({
  library(readr) # Para cargar las tablas 
  library(ggplot2) # Manipulación de datos
  library(ggthemes)
  library(readxl)
  library(reshape2)
})

# **** EJECUTAR ESTAS LINEAS PARA ARMAR UN ÚNICO GRÁFICO DE UN ÚNICO AÑO

# Directorio donde se encuentran los datos normalizados a leer
path="/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/NORM/"

# Año de interés
YYYY="2017"

# Estación de interés
STAT="SAZG"

# Variable de interés (Comente las líneas que NO desea graficar, con un "#")
#var="PRE_stat"
#var="PRE_mar"
#var="TEMP"
var="HUM"
#var="PREC"

file=list.files(paste0(path,"/",YYYY),pattern=STAT,full.names = TRUE)

datos=read_csv(file,col_names = c("DATE","PRE_stat","PRE_mar","TEMP","HUM","PREC"),
               show_col_types = FALSE)

ggplot(datos)+geom_point(aes(x=DATE,y=get(var)),colour="darkred",size=2)+
  theme_calc()+
  labs(x="Date",y=var)

# **** EJECUTAR ESTAS LINEAS PARA GRAFICAR UN ACUMULADO POR CADA VARIABLE
## Y POR CADA ESTACIÓN

path_param="/nfs/gps2/sd0/proyectos/Datos_MET/parametros.txt"

# Leo parámetros
parametros=read_delim(path_param,
                      skip=4,
                      skip_empty_rows = TRUE,
                      col_names = c("Par","valor"),
                      col_types = cols(),
                      delim="=",progress = FALSE)

equal=as.character(parametros[which(parametros$Par == "smn_equivalencias"),2])

# Leo el archivo de datos históricos y listado de estaciones
equivalencias=read_excel(equal,sheet="equivalencias")

# Directorio donde se encuentran los datos normalizados a leer
path="/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/NORM"

source('/nfs/gps2/sd0/proyectos/Datos_MET/00_programas/outliers.R')

for (i in 1:nrow(equivalencias)){
  
  OUT=NULL
  
  OMM=equivalencias$OMM[i]
  
  OACI=equivalencias$OACI[i]
  
  name=equivalencias$STATS.txt[i]
  
  if (is.na(name) == TRUE){
    name=equivalencias$stats_TP[i]
  } 
  
  if (is.na(name) == TRUE) {
    name=equivalencias$stats_DH[i]
  } 
  
  if (is.na(name) == TRUE) {
    name=equivalencias$stats_DH2[i]
  } 
  
  if (is.na(name) == TRUE) {
    name=equivalencias$stats_DH3[i]
  }
  
  print("***")
  print(paste0(name," - ",i," de ",nrow(equivalencias)))
  print("***")
  
  for (j in 2017:2022){
    
    file=(paste0(path,"/",j,"/",OMM,"_",OACI,".txt"))
    
    if (file.exists(file) == TRUE){
      dati=read_csv(file,col_names = c("DATE","PRE_stat","PRE_mar","TEMP","HUM","PREC"),
                    show_col_types = FALSE)
      
      dati$DATE=as.POSIXct(dati$DATE,format="%Y-%m-%d %H:%M:%S",tz="UTC")
      
      OUT=rbind(OUT,dati)
    }
    
  }
  
  #datos=OUT
  
  if (is.null(OUT) == FALSE){
    
    OUT2=OUT
    
    # Remuevo outliers en las columas de Presión (ambas) y temperatura
    for (k in 2:4){
      var=colnames(OUT2)[k]
      remove_outliers(OUT2,var,5)->datos_filt
      if (nrow(datos_filt) != 0) {
        OUT2=datos_filt
      }
      
    }
    
    datos=melt(OUT2,na.rm=FALSE,id="DATE")
    
    ps=ggplot(datos)+geom_point(aes(x=DATE,y=value,colour=variable),size=0.15)+
      theme_calc()+ labs(x="Date",y="Variables")+
      ggtitle(paste0("Datos meteorológicos disponibles para: ",name))+
      facet_wrap(~variable,ncol=3,scales = "free")+guides(colour=FALSE)
    
    ps_name=paste0("/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/GRAPH/",OMM,"_",OACI,".jpeg")
    ggsave(ps_name,plot = ps,dpi=300, width = 30, height = 15,units="cm")
    
  } 
  
} # Fin loop por estación

# Armo una gráfica para ver la continuidad de los datos de tiempo presente
## y los horarios

# Busco listado de datos crudos
smn_datohorario_row=as.character(parametros[which(parametros$Par == "smn_datohorario_row"),2])

smn_datoTP_row=as.character(parametros[which(parametros$Par == "smn_datoTP_row"),2])


TP=list.files(smn_datoTP_row,pattern = "tiepre",full.names = FALSE)
  TP_date=as.Date(substr(TP, 7, 14),format="%Y%m%d")

hor=list.files(smn_datohorario_row,pattern = "datohorario", recursive = TRUE, full.names = FALSE)
  hor_date=as.Date(substr(hor,17,24),format="%Y%m%d")

par(mar=c(1,1,1,1))

g=ggplot()+
  geom_point(aes(x=TP_date,y="TP",colour="TP: Tiempo presente"),size=0.3)+
  geom_point(aes(x=hor_date,y="DH",colour="DH: Dato horario"),size=0.3)+
  labs(x="Date",y="Tipo de dato",colour = "Tipo de dato")

g_name=paste0("/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/GRAPH/_serie_datos.jpeg")
ggsave(g_name,plot = g,dpi=300, width = 30, height = 7,units="cm")






# INDIVIDUALES

par(mar=c(1,1,1,1))

# PRESION A NIVEL DEL A ESTACIÓN
ps=ggplot(datos)+geom_point(aes(x=DATE,y=PRE_stat),colour="darkred",size=2)+
  theme_calc()+ labs(x="Date",y="Presión [hPa]")+
  ggtitle(paste0("Presión a nivel de la estación. Sitio: ",name))

ps_name=paste0("/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/GRAPH/",OMM,"_",OACI,"_PRE_stat.jpeg")
ggsave(ps_name,plot = ps,dpi=300, width = 30, height = 15,units="cm")

# PRESIÓN A NIVEL DEL MAR
pm=ggplot(datos)+geom_point(aes(x=DATE,y=PRE_mar),colour="darkred",size=2)+
  theme_calc()+ labs(x="Date",y="Presión [hPa]")+
  ggtitle(paste0("Presión a nivel del mar. Sitio: ",name))

pm_name=paste0("/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/GRAPH/",OMM,"_",OACI,"_PRE_mar.jpeg")
ggsave(pm_name,plot = pm,dpi=300, width = 30, height = 15,units="cm")

# TEMPERATURA
temp=ggplot(datos)+geom_point(aes(x=DATE,y=TEMP),colour="darkblue",size=2)+
  theme_calc()+ labs(x="Date",y="Temperatura [ºC]")+
  ggtitle(paste0("Temperatura a 2 m del suelo. Sitio: ",name))

temp_name=paste0("/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/GRAPH/",OMM,"_",OACI,"_TEMP.jpeg")
ggsave(temp_name,plot = temp,dpi=300, width = 30, height = 15,units="cm")

# HUMEDAD
hum=ggplot(datos)+geom_point(aes(x=DATE,y=HUM),colour="darkgreen",size=2)+
  theme_calc()+ labs(x="Date",y="Humedad [%]")+
  ggtitle(paste0("Humedad. Sitio: ",name))

hum_name=paste0("/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/GRAPH/",OMM,"_",OACI,"_HUM.jpeg")
ggsave(hum_name,plot = hum,dpi=300, width = 30, height = 15,units="cm")

# PRECIPITACIONES
prec=ggplot(datos,aes(x=DATE,y=PREC))+geom_bar(stat= "identity",colour="darkviolet",size=2)+
  theme_calc()+ labs(x="Date",y="Precipitaciones [mm]")+
  ggtitle(paste0("Precipitaciones. Sitio: ",name))

prec_name=paste0("/nfs/gps2/sd0/proyectos/Datos_MET/ARG/SMN/GRAPH/",OMM,"_",OACI,"_PREC.jpeg")
ggsave(prec_name,plot = prec,dpi=300, width = 30, height = 15,units="cm")
