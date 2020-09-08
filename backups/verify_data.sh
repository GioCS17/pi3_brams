#!/bin/bash
# Step 1: Initial Variables and Arguments

startDate=$1 #Date & Time to be converted ->Format: “YYYYMMDDHH” ie:2019031000
maxTime=$2  #Number of hours to predict ie: 72
dpsDirectory=$3 #DPS destiny folder

intervalHour=6 #We consider 6 hours by interval
edateWithoutHours=$(echo "${startDate}" | cut -c 1-8) #i.e 20190310
edateHours=$(echo "${startDate}" | cut -c 9-10) #i.e 00
dpFilenames=()

for index in $(seq 0 $(( maxTime/intervalHour )))
do
    dpFilenames[$index]=$(date +%Y-%m-%d-%H00 -d "$edateHours:00:00 $edateWithoutHours $(( $intervalHour * $index )) hours")
done

# Step 2: Verify if the DP's are already downloaded and if they are, verify that the size of each one 
# be the correct (all dp should have the same size)

# TODO: Confirm and Remove the file size analysis, because with file existance is enough and analyze the file size 
# could make problems with future files 

DP_FILE_SIZE=199577651 #IMPORTANT: This is the standard size of DP File
flag_dp_exists=1 #We consider the DP Files exists

for dpFilename in "${dpFilenames[@]}"
do
    if ! test -s "${dpsDirectory}/0dp${dpsFilename}"; then
        echo "DP File not founded: $dpsDirectory/dp$dpFilename"
        flag_dp_exists=0
    else
        #TODO
        dpFileSize=$(ls -l $dpsDirectory/dp$dpFilename | awk '{print $5}')
        if [ ${dpFileSize} -ne ${DP_FILE_SIZE} ]; then
            echo "DP Wrong Size ${DP_FILE_SIZE}<>${dpFileSize} :" "$dpsDirectory/dp$dpFilename"
            flag_dp_exists=0
        fi
    fi
done