#This script save the GFS Files on Disk to be converted by GeraDP
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

DiaFolder=`date --date="$incomingDate" +%d`
Dia=`date --date="$incomingDate" +%Y%m%d`
echo $Dia
DiaPost=`date --date="$incomingDate +1 day" +%Y%m%d`
echo $DiaPost

#Carpeta Donde se guardan los datos
CarpetaDatos=$1

#Prefijo para la carperta de datos observados
PrefijoObserved="nasa_data"

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
if [ ! -d $CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoObserved ]; then
    mkdir $CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoObserved
fi

cd $CarpetaDatos/$Ano/$MesFolder/$DiaFolder/$PrefijoObserved

#Directorio Web Donde se Descargan los Datos
webAddress="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs."
dayWebFolder=$webFTPAddressPrefix$Dia/

for i in `seq 0 4`
do
    multipliedNumber=`expr $i \* 6`
    hourPad=`printf %02d $multipliedNumber`
    downloadDay=$Dia
    if [ $i -eq 4 ]; then
        hourPad="00"
        downloadDay=$DiaPost
    fi
    resultFiles=`curl -s $webAddress$downloadDay$hourPad/ | grep -Eoi '<a [^>]+>' |  grep -Eo 'href="[^\"]+"' |  grep -Eo 'gfs.t.*z.pgrb2.0p25.f(.*)[^\"]+'`
    for link in $resultFiles
    do
        wget -nc $webAddress$downloadDay$hourPad/$link
    done
done
#echo $destinyFolder