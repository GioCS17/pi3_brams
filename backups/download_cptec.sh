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

#Creamos las carpetas por año,mes,dia,prediccion u observación
if [ ! -d $CarpetaDatos ]; then
	mkdir $CarpetaDatos
fi
if [ ! -d $CarpetaDatos/$Ano ]; then
    mkdir $CarpetaDatos/$Ano
fi
if [ ! -d $CarpetaDatos/$Ano/$MesFolder ]; then
    mkdir $CarpetaDatos/$Ano/$MesFolder
fi
if [ ! -d $CarpetaDatos/$Ano/$MesFolder/$DiaFolder ]; then
    mkdir $CarpetaDatos/$Ano/$MesFolder/$DiaFolder
fi
if [ ! -d $CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoPredicted ]; then
    mkdir $CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoPredicted
fi
if [ ! -d $CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoObserved ]; then
    mkdir $CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoObserved
fi

#Directorio Web Donde se Descargan los Datos
webFTPAddressPrefix="ftp://ftp1.cptec.inpe.br/modelos/io/tempo/global/T126L28/"

webDayDirectory="$Dia"00""
destinyFolder=$CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoObserved
filePrefix=$webFTPAddressPrefix$webDayDirectory/GAMRAMS$webDayDirectory
for i in `seq 0 4`
do
    multipliedNumber=`expr $i \* 6`
    hourPad=`printf %02d $multipliedNumber`
    format="icn"
    downloadDay=$Dia
    [[ $i -gt 0 ]] && format="fct"
    if [ $i -eq 4 ]; then
        hourPad="00"
        downloadDay=$DiaPost
    fi
    wget -nc  $filePrefix$downloadDay$hourPad"P.$format.TQ0126L028.ctl" -P $destinyFolder
    wget -nc  $filePrefix$downloadDay$hourPad"P.$format.TQ0126L028.gmp" -P $destinyFolder
    wget -nc  $filePrefix$downloadDay$hourPad"P.$format.TQ0126L028.grb" -P $destinyFolder
done
echo $destinyFolder