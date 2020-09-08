#!/bin/bash

variables=(
    tlcor_1000 # Temperatura y viento (1000 hPa)
    tlcor_950 # Temperatura y viento (950 hPa)
    tlcor_850 # Temperatura y viento (850 hPa)
    tlcor_500 # Temperatura y viento (500 hPa)
    JATO_DIVG # Jet Stream
    adv_vort # Adveccion de Vort.
    PV # Vorticidad potencial (300hPa)
    isent_320_pv # Isentrópico 320°K
    vort_500 #  Vorticidad R. (500hPa)
    THCK # Presión nm/espesor (500/1000hPa)
    relh_vvel_500 # Omega/H. Relativa (500hPa)
    lcor_10m # Linea de Corriente a 10 metros
    lcor_150 # L. Corriente (150hPa)
    lcor_200 # L. Corriente (200hPa)
    lcor_300 # L. Corriente (300hPa)
    lcor_400 # L. Corriente (400hPa)
    lcor_500 # L. Corriente (500hPa)
    lcor_850 # L. Corriente (850hPa)
    lcor_700 # L. Corriente (700hPa)
    lcor_950 # L. Corriente (950hPa)
    lcor_1000 # L. Corriente (1000hPa)
    advt_850 # Advección de temp. (850 hPa)
    advt_925 # Advección de temp. (925 hPa)
    advt_950 # Advección de temp. (950 hPa)
    advt_975 # Advección de temp. (975 hPa)
    advt_1000 # Advección de temp. (1000 hPa)
    relh_850 # H. relativa (850 hPa)
    relh_700 # H. relativa (700 hPa)
    relh_600 # H. relativa (600 hPa)
    relh_300 # H. relativa (300 hPa)
    dwpt_925 # Temperatura de Rocio (925 hPa)
    flux # Flujo de humedad (600hPa)
    conv_div # Convergencia/Divergencia
    conv_hum_850 # Convergencia de Hum. (850 hPa)
    conv_hum_950 # Convergencia de Hum. (950 hPa)
    SA_LLJ # Jet de bajos niveles (850 hPa)
    LOWJ_COAST # Jet bajos niveles Costero (950hPa)
    indice_K_pwat # Índice K
    SWEAT # Índice Sweat
    INDT # Índice Total de Totales
    INDC # Índice Cape
    prec_south_06h # Precipitación SA 06h
    prec_PERU_06h # Precipitación PE 06h
    prec_peru_24h # Precipitación PE 24h
    nieve_south_america # selected="">Nieve SA 06h
    nieve_peru # Nieve PE 06h
    granizada # Granizada sobre Lat. Medias
    Corte_conv # Corte 5° sur
    Corte_conv10s # Corte 10° sur
    Corte_conv12s # Corte 12° sur
    Corte_conv15s # Corte 15° sur
    Corte_conv20s # Corte 20° sur
    Corte_conv25s # Corte 25° sur
    IndiceNevadas # Indice de Nevadas
    Enfriamiento # Potencial de Enfriamiento
)


######################## MAIN #####################################

###### ARGS #######
selectedDate=$1 #Date & Time to be converted ->Format: “YYYYMMDD” ie:20190310
[[ -z $1 ]] && selectedDate=`date +%Y%m%d`
maxTime=120  #Number of hours to predict ie: 120

#################### CONSTANTS ############################
url="https://www.senamhi.gob.pe/usr/dms/modelo/modeloeta"
directory="/data/dataout/SENAMHI/${selectedDate}"

if [ ! -d "${directory}" ]; then
    mkdir ${directory}
fi

for variableSelected in "${variables[@]}";
do
    if [ ! -d "${directory}/${variableSelected}" ]; then
        mkdir ${directory}/${variableSelected}
    fi

    range="0 6 ${maxTime}"
    suffix="f"
    case ${variableSelected} in
        Enfriamiento)
            range="1 8"
            suffix="dia"
            ;;
        prec_peru_24h)
            range="24 12 ${maxTime}"
            suffix="f"
            ;;
        *)
            range="0 6 ${maxTime}"
            suffix="f"
            ;;
    esac
    for index in `seq ${range}`;
    do
        if [ ! -f "${directory}/${variableSelected}/${variableSelected}_${suffix}${index}.gif" ]; then
            #wget -c -P ${directory}/${variableSelected}  ${url}/${variableSelected}_f${index}.gif
            aria2c -x16 -s16 -d ${directory}/${variableSelected} -c --summary-interval=0  ${url}/${variableSelected}_${suffix}${index}.gif
        fi
    done
    if [ ! -f "${directory}/${variableSelected}/${variableSelected}.gif" ]; then
        echo "Creating GIF ${variableSelected}" 
        convert -delay 20 -loop 0 `ls -d -v ${directory}/${variableSelected}/*` ${directory}/${variableSelected}/${variableSelected}.gif
    fi
done