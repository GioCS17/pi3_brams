#!/usr/bin/env bash

#Argumentos
#$1 Nombre de la Carpeta
#$2 Fecha en Formato (20190205)


#Descarga de Datos
#Variables de Año,Mes,Dia

incomingDate=$2
[[ -z $2 ]] && incomingDate=`date +%Y%m%d`

Ano=`date --date="$incomingDate" +%Y`
Mes=`date --date="$incomingDate" +%Y%m`
MesFolder=`date --date="$incomingDate" +%m`
Dia=`date --date="$incomingDate" +%Y%m%d`
DiaFolder=`date --date="$incomingDate" +%d`
DiaPost=`date --date="$incomingDate" +%Y%m%d -d '+1 day'`

#Carpeta Donde se guardan los datos
CarpetaDatos=$1

#Prefijo para la carperta de datos predichos
PrefijoPredicted="predicted"
#Prefijo para la carperta de datos observados
PrefijoObserved="observed"
destinyFolder=$CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoObserved
echo $destinyFolder