#########################################
# SERVICIO METEOROLÓGICO NACIONAL - SMN #
#########################################

Última actualización: 12/12/2022

# Sobre archivo log_smn

	Este archivo contiene la información de la última fecha procesada de datos de tiempo presente y horarios (no se modifica al normalizar los datos historicos). Esto permite al programa saber cuál fue la última fecha procesada y así evitar comenzar desde el archivo más antiguo. Si este archivo no existe, el programa entenderá que deberá empezar desde la fecha más vieja de todos los datos que tenga (sólo horario y de tiempo presente). Puede editarlo manualmente si quiere que se reprocese desde una determinada época. La fecha final siempre a la fecha corriente.
	Si usted desea correr la generación de los acumulados anuales pero sin eliminar todos los datos, puede eliminar este archivo log y correr el programa que corresponda. De esta manera, genera los acumulados con los datos a tiempo presente y horarios, sin eliminar los archivos que se hayan generado previamente.
	
# Sobre listado de estaciones STATS.txt

	Última descarga de estaciones: 25/11/2022

	Si el listado de estaciones requiere una actualización, antes de correr los programas de normalización de listado de estaciones debe tener en cuenta lo siguiente:

	1. Guarde el archivo de estaciones descargado dentro de la carpeta "aux" y ábralo con un editor de texto plano (No en word ni google docs). Controle que en el archivo de parámetros figure la ruta correcta.
	2. Elimine las filas en que la abreviación "AERO" quedó cortada (Suelen ser sólo dos, en Chaco y Cordoba).
	3. No deje líneas en blanco y procure no eliminar texto de las líneas completas.
	4. Elimine el remanente "AE" (o cualquiera que quede) que figura al final de las estaciones que sufrieron en corte mencionado en el paso 2 y reemplácelo por espacios. Asegúrese de que todos los datos queden al mismo nivel. Esto último no es una cuestión estética, sino porque el script que leerá ese archivo lo hará por ancho de columnas y no por separadores.
	5. Guarde los cambios realizados en el listado de estaciones.
	6. Corra el programa "genera_stats_smn.R" ubicando dentro de "00_programas/SMN". Si todo corrió correctamente, el programa se lo indicará con un mensaje.
	
	Si desea agregar estaciones manualmente, puede hacerlo en el archivo "STATS.txt" SIEMPRE Y CUANDO respete el formato de los datos.	
	
# Sobre listado de equivalencias

	Última actualización del archivo: 06/12/2022

	Este archivo es necesario hacerlo a mano, dada la falta de homogeneidad en los nombres de las estaciones meteorológicas del SMN. El archivo contiene, a la fecha de actualización, la siguiente información:
	OMM: Número OMM, como figura en el listado de estaciones descargado de internet
	OACI: Código OACI, como figura en el listado de estaciones descargado de internet
	STATS.txt: Nombres de las estaciones, como figuran en el listado de estaciones descargado de internet
	stats_TP: Nombre de las estaciones, como figuran en el archivo de Tiempo Presente (En mayúsculas y sin tildes)
	stats_DH: Nombre 1 de las estaciones, como figuran en el archivo de Dato Horario (En mayúsculas y sin tildes)
	stats_DH2: Nombre 2 de las estaciones, como figuran en el archivo de Dato Horario (En mayúsculas y sin tildes)
	stats_DH3: Nombre 3 de las estaciones, como figuran en el archivo de Dato Horario (En mayúsculas y sin tildes)
	
	Estos últimos 3 tipos de nombres, no son cambios drásticos, sino errores por la falta de una o pocas letras, que hacen que los filtros por estaciones no encuentren datos. Si se detectara una estación que tiene un nombre distinto al propuesto en la columna "stats_DH", puede agregarlo en las columnas siguientes, sin importar el órden (el programa realizará diversos filtros hasta encontrar el que brinda datos de salida). Por ahora, este problema se detecta únicamente en las estaciones presentes en los datos horarios.
	
	Mantener esta tabla actualizada será tedioso, pero por ahora no tengo otra solución.
	
	A futuro, generaré un script para controlar la cantidad de estaciones presentes en cada archivo (aunque si estas estaciones no tienen coordenadas, como las que están en los listados que se pueden descargar del SMN, es medio inutil tenerla, ya que no le podemos asignar una estación GNSS cercana). Aún así, no veo malo tener los datos de esas estaciones.
	
	Hay algunas estaciones que tienen datos en tiempo presente, pero no presentan valores ni de OMM ni de OACI. En este caso, se inventó un código "OACI" con las siglas del lugar donde se encuentra la estación, seguido de XX para completar los 4 dígitos solicitados.
	
	Este es el archivo ideal si usted desea incorporar nuevas estaciones a los listados. 	

# Sobre datos

	*** dato_horario: Datos procesados por el SMN. Se encuentran filtrador por información de interés y con la presión reducida al nivel del mar o a niveles de presión. Estos datos se descargan manualmente mediante la ejecución de un script generado por Andrés (descarga.py). Los datos no están almancenados en la carpeta máster, sino que es un link de acceso directo (link simbólico) a la carpeta "/nfs/gps1/sd0/proyectos/datohorario_smn". Tenga en cuenta que no todos los programas admiten la lectura de un acceso directo. Ante esto, deberá indicar como ruta de acceso la dirección original y no el enlace.

	*** dato_tiempopresente: Datos publicados cada una hora, donde se describen parámetros como la visibilidad y precipitaciones. La presión se encuentra a nivel de la estación. Estos archivos se actualizan cada una hora, mediante la ejecución de un script hecho por Fernanda. Los datos no están almancenados en la carpeta máster, sino que es un link de acceso directo (link simbólico) a la carpeta "/nfs/gps1/sd0/proyectos/SMN". Tenga en cuenta que no todos los programas admiten la lectura de un acceso directo. Ante esto, deberá indicar como ruta de acceso la dirección original y no el enlace.

	*** historico: Este excel es el que le compró Virginia al SMN en el 2017. Presenta los datos historicos de las estaciones de la red dentro de la pestaña "DATOS" y abarca el periodo 2015 a 2017 (casi todo el año). Son sólo 21 estaciones, del as cuales sólo 19 presentan número OMM, una con número desconocido y otra sin ningún tipo de información (Habría que encontrar qué estación es - trabajo pendiente a la fecha de actualización de este manual). De toda la información disponible, sólo se extrae: Número OMM, fecha, hora UTC, temperatura [ºC], presión a nivel de la estación [hPa], presión a nivel del mar [hPa] y precipitaciones [mm]. Como estos datos no cuentan con valores de humedad, esta columna se genera igual para mantener el formato de los datos.
	
# Sobre programas

	Los programs destinados a manipular los datos del SMN se encuentran dentro de: 00_programas/SMN
	
	genera_norm_smn.R: Este es el programa base, que lee los datos horarios y de tiempo presente y los unifica en un únic archivo. Genera un acumulado por año y por cada estación, y lo almancena siguiendo los códigos OMM y OACI de cada estación. Este programa llama a otras funciones que se encargan de la lectura de los datos de tiempo presente (busca_TP_smn.R) y los datos horarios (busca_DH_smn.R). También, llama a otra función que se encarga de generar el archivo acumulado de cada estación (guarda_norm_smn.R) y lo almancena dentro de la carpeta correspondiente.
	
	genera_stats_snm.R: Este programa lee el archivo de estaciones descargado del SMN (y previamente editado, tal como se indicó en la sección "Sobre listado de estaciones") y genera otro, denominado STATS.txt.
	
	lee_historico.R: Este programa lee el archivo de datos históricos y separa los datos por estación. Luego, unifica los datos con los ya existentes o genera archivos nuevos, en caso de no existir. Este programa permite la lectura de archivos con el formato enviado por el SMN (O, al menos, con los que tenemos actualmente). Los archivos que se pueden leer con este programa son:
	** datos estaciones meteorologicas 2015-2016.xlsx
	** EXP_DATOS_2015.xlsx
	** EXP_165624.xlsx
	Si se consiguieran archivos con otros periodos pero que mantienen el mismo formato que los previamente mencionados, el programa debería leerlos sin problemas. Igualmente, es importante que se toman las siguientes precauciones antes de poner a correr el programa:
	1. Se debe modificar el archivo de parámetros con ruta completa al directorio donde se encuentran los datos (variable "smn_historico"). Incluir el nombre del archivo y su extensión (No he probado este programa con archivos de excel con la extensión vieja, es decir, con el "xsl" - No garantizo que funcione para con otras extensiones a la nueva "xlsx")
	2. La pestaña del excel con los datos debe llamarse "DATOS" (en mayúsculas y sin comillas)
	3. El programa saltea las primeras 25 líneas, por lo que es importante que, si no existen, se agreguen tantas filas como sea necesario, para que el encabezado de los datos comience en la línea 26. No importa el órden de las líneas vacías, lo importante es que el encabezado esté en la línea 26.
	4. El órden de los datos es:
	A		NUMERO INTERNACIONAL
	B		FECHA
	C		HORA UTC
	D		TEMP TERMOMETRO SECO
	E		PLAFOND
	F		VISIBILIDAD
	G		NUBOSIDAD TOTAL
	H		DIRECCION VIENTO
	I		INTENSIDAD DE VIENTO EN NUDOS
	J		TEMPERATURA DE ROCIO
	K		PRESION A NIVEL ESTACION
	L		PRESION A NIVEL MAR
	M		TENDENCIA DE LA PRESION
	N		FORMA DE LA TENDENCIA
	O		TIEMPO PRESENTE
	P		PRIMER TIEMPO PASADO
	Q		SEGUNDO TIEMPO PASADO
	R		GRADO DE NUBES BAJAS
	S		FORMA DE NUBES BAJAS
	T		FORMA DE NUBES ALTAS
	U		FORMA DE NUBES MEDIAS
	V		PRECIPITACION DE ULTIMAS 6 HS
	5. Eliminar la última fila, ya que contiene un número identificatorio (de vaya uno a saber qué), el cual no pertenece a ninguna estación meteorológica y tampoco posée datos de interés. Si esta fila no se elimina, se generará una carpeta llamada "NA" (dentro de NORM) que contendrá un txt vacio. Todo eso debe eliminarse a mano, por eso, si se eliminó previamente esta línea del archivo, esta carpeta no se debería generar.
	
	Las columnas importantes (y las que deberían mantener su nombre, son: 
	A		NUMERO INTERNACIONAL
	B		FECHA
	C		HORA UTC
	D		TEMP TERMOMETRO SECO
	K		PRESION A NIVEL ESTACION
	L		PRESION A NIVEL MAR
	V		PRECIPITACION DE ULTIMAS 6 HS
		
	Las demás columnas no son importantes para nuestros intereses. Por lo tanto, si llegara a haber una variación en los encabezados, generar el cambio de acuerdo a este último listado. No importa el orden de las columnas, lo importante es el nombre. Después el programa de encarga de cambiar las cosas de lugar. 
	
	lee_historico_2.R: Este programa lee el archivo de datos históricos y separa los datos por estación. Luego, unifica los datos con los ya existentes o genera archivos nuevos, en caso de no existir. Se difernecia del "lee_historicos.R" ya que este programa lee datos que estan organizados en distinta cantidad y estilo de datos. 
	El archivo que se puede leer con este programa es:
	** EXP_171790.xlsx

	Si se consiguieran archivos con otros periodos pero que mantienen el mismo formato que los previamente mencionados, el programa debería leerlos sin problemas. Igualmente, es importante que se toman las siguientes precauciones antes de poner a correr el programa:
	1. Se debe modificar el archivo de parámetros con ruta completa al directorio donde se encuentran los datos (variable "smn_historico"). Incluir el nombre del archivo y su extensión (No he probado este programa con archivos de excel con la extensión vieja, es decir, con el "xsl" - No garantizo que funcione para con otras extensiones a la nueva "xlsx")
	2. La pestaña del excel con los datos debe llamarse "DATOS" (en mayúsculas y sin comillas)
	3. El programa saltea las primeras 3 líneas, por lo que es importante que, si no existen, se agreguen tantas filas como sea necesario, para que los datos comiencen en la línea 4 (estos datos se consideran sin encabezado). No importa el órden de las líneas vacías
	4. El órden de los datos es:
	ESTACION
	FECHA
	HORA LOCAL
	TEMPERATURA
	PRESION A NIVEL DE ESTACION
	PRESION A NIVEL DE MAR
	5. Este archivo tiene mas de 900 mil líneas, por lo que leerlo consume mucha memoria y por lo tanto, puede generar que el programa demore mucho en finalizar. Tenga paciencia.
	
	Puede utilizar este programa para leer cualquier tipo de archivo que tenga el mismo formato que el detallado en el punto 4. 
	
	busca_stat.R: Este programa está pensado para que la el programa busque datos de todas las variantes de nombres que puede tener una estación. Actualmente, la búsqueda se realiza sobre 4 nombres distintos. El programa primero buscará datos por un nombre, y si no encuentra, pasará a buscar datos por las otras 3 variantes que puedan llegar a existir. En caso de no encontrar ninguno, el programa brindara resultados nulos.
	

