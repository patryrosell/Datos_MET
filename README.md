# Datos_MET

This project is part of the [Geodesy and Georeferencing Research Group](https://ingenieria.uncuyo.edu.ar/grupo-de-investigacion-aplicado-a-la-geodesia-y-georreferenciacion) of the SIRGAS Analysis Centre for the Neutral Atmosphere (CIMA)

## Status

Active

## Objetive

This project aims to import, tidy and transform meteorological data into a unique format and plotting the accumulated data. This will allow providing Integrated Water Vapour (IWV) in quasi-real-time, from the [Zenital Tropospheric Delays (ZTD) of the SIRGAS network](https://sirgas.ipgh.org/productos/retrasos-troposfericos/). 

## Institutions involved

- Facultad de Ingeniería ([FING](https://ingenieria.uncuyo.edu.ar/)) - Univesidad Nacional de Cuyo (Mendoza, Argentina)
- Facultad de Ingeniería y Enología ([INE](https://www.umaza.edu.ar/facultad-de-INE)) - Universidad Juan Agustín Maza (Mendoza, Argentina)
- Consejo Nacional de Investigaciones Científicas y técnicas ([CONICET](https://www.conicet.gov.ar/))

## Getting started

1. Clone this repo
2. Fill the parameters file (parametros.txt) with the absolute paths to the raw data and storing folders. Also, indicate the values of parameters involved in the plotting stage. For more information, read the User's Manual.
3. In an R terminal, change to the main directory (Datos_MET) and run "main.R" with the following arguments:
	- Name of data provider (Currently, only available for "[SMN](https://www.smn.gob.ar/descarga-de-datos)")
	- Absolute path to parameters file (parametros.txt -> Don't forget to fill it!)
	- Absolute path to programs folder (00_programas)
4. A sample of raw & formatted data within output graphics are provided in the RAW and GRAPH folders of ARG/SMN.

## Last update: 

01-18-2013

## Author

Patricia A. Rosell, Ph.D.

## Contact info

patryrosell[at]gmail.com
