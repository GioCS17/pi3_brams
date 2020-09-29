#!/bin/bash

######################## FUNCTIONS #####################################

function runBrams {
    printf "\nRunning BRAMS...\n"
    ulimit -s 65536

    #Modifying Values RAMSIN
    monthString=`grep -i '! Month' RAMSIN`
    dateString=`grep -i '! Day' RAMSIN`
    yearString=`grep -i '! Year' RAMSIN`
    runTypeString=`grep -i '! Type of run' RAMSIN`

    actualMonthString="   IMONTH1  =${startDate:4:2},      ! Month"
    actualDateString="   IDATE1  =${startDate:6:2},      ! Day"
    actualYearString="   IYEAR1  =${startDate:0:4},      ! Year"
    actualRunTypeString="   RUNTYPE  = '${runType}',    ! Type of run: MAKESFC, INITIAL, HISTORY,"

    #sed -i "s/$monthString/$actualMonthString/" RAMSIN
    #sed -i "s/$dateString/$actualDateString/" RAMSIN
    #sed -i "s/$yearString/$actualYearString/" RAMSIN
    sed -i "s/$runTypeString/$actualRunTypeString/" RAMSIN

    if [ ! -d $carpetaDatos/IVAR/$startDate ]; then
        mkdir $carpetaDatos/IVAR/$startDate
    fi

    if [ ! -d $carpetaDatos/HIS/$startDate ]; then
        mkdir $carpetaDatos/HIS/$startDate
    fi

    if [ ! -d $carpetaDatos/ANL/$startDate ]; then
        mkdir $carpetaDatos/ANL/$startDate
    fi

    if [ ! -d $carpetaDatos/UMIDADE/$startDate ]; then
        mkdir $carpetaDatos/UMIDADE/$startDate
    fi

    if [ "$runType" = "MAKESFC" ] || [ "$runType" = "MAKEVFILE" ]; then
        mpirun -np 1 brams
    else
        mpirun -np 4 brams
    fi
}

######################## MAIN #####################################

startDate=$1 #Date & Time to be converted ->Format: “YYYYMMDDHH” ie:2019031000
runType=$2

carpetaDatos='/data/dataout/'

runBrams
