#! /bin/bash 
# Objetivo--: gerar os dps
# Autor-----: Denis Eiras
# Data------: 11/11/2018

# Compiling wgrib2 v2.0.6+
# Compiling wgrib2 is easy on a linux system with gcc/gfortran or Windows with the cygwin compilers
# 1) Download ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz
# 2) remove pre-existing grib2 directory if exists: rm -r grib2
# 3) untar wgrib2.tgz:  tar -xzvf wgrib2.tgz   (use gnu tar)
# 4) cd to main directory:  cd grib2
# 5) define the C and fortran compilers and make
#    Bash:
#      export CC=gcc
#      export FC=gfortran
#      make
#      make lib                        only if you want the ftn_api
#    Csh
#      setenv CC gcc
#      setenv FC gfortran
#      make
#      make lib                        only if you want the ftn_api
# 6) See if wgrib2 was compiled
#      wgrib2/wgrib2 -config

# note: you may have to install gcc and gfortran

function verifica () {
################################ VERIFICA SE OS DADOS DO GFS ESTAO CORRETOS #########################################
cont=0 ; n_wait=10
HHH=000
DATA=$1
DATAF=$2
while [ "${DATA}" -le "$DATAF" ] ; do
    hfinal=0157
    if [ "$HHH" -eq 000 ] ; then
        hfinal=0157
    fi
    final=$(${wgrib2} -match "UGRD|VGRD|TMP|HGT|RH" -match " mb:|:surface:" $DPS_DIR/gfs.t${edate:8:10}z.pgrb2.0p25.f${HHH}.${edate}.grib2 | wc -l)
    if [ 0$(${wgrib2} -match "UGRD|VGRD|TMP|HGT|RH" -match " mb:|:surface:" $DPS_DIR//gfs.t${edate:8:10}z.pgrb2.0p25.f${HHH}.${edate}.grib2 | wc -l) == "${hfinal}" ] ; then
        echo "$DPS_DIR/gfs.t${edate:8:10}z.pgrb2.0p25.f${HHH}.${edate}.grib2 CORRETO"

        DATA=$(date -d "${DATA:0:8} ${DATA:8:10}:00 6 hours" +"%Y%m%d%H")
        HHH=$(echo "$HHH+6" | bc )
        HHH=$(echo "$HHH" | awk '{ printf ("%.3d\n", $1)}')
    else
        echo "$DPS_DIR/gfs.t${edate:8:10}z.pgrb2.0p25.f${HHH}.${edate}.grib2 INCOMPLETO"

        let cont="$cont"+1
        if [ $cont -ge "$n_wait" ] ; then
            echo "PROBLEMA NA PUXADA DO $DPS_DIR/gfs.t${edate:8:10}z.pgrb2.0p25.f${HHH}.${edate}.grib2"
            exit 1
        fi
        sleep 60
    fi
done
}

###########################################################################################
function verifica_dps () {
### Verificando se os dp´s estao OK ###
existe_dp=1
t=1
tam_dp=199577651
while [ $t -le "$tmax_dp" ]; do
    if ! test -s "${DPS_DIR}/dp${data_arr[$t]}"; then
        echo "Nao foi encontrado o dp: ${DPS_DIR}/dp${data_arr[$t]}"
        existe_dp=0
    else
        tam=$(ls -l ${DPS_DIR}/dp${data_arr[$t]} | awk '{print $5}')
            if [ ${tam} -ne ${tam_dp} ]; then
            echo "dp com tamanho errado ${tam_dp}<>${tam} :" "${DPS_DIR}/dp${data_arr[$t]}"
            existe_dp=0
        fi
    fi
    t=$(expr $t + 1)
done
if [ "$existe_dp" -eq 1 ]; then
    echo "DPs Gerados anteriormente: ${edate}"
fi
}
###########################################################################################

# INICIO ...
# set -x

hh_now=$(date +%H)
amd_now=$(date +%Y%m%d)
hh=00

echo "${edate}" > data_run.txt
export edate

### Encontrando as datas para os dp's ###
t=1; horas=0; int_dp=6
amd=$(echo "${edate}" | cut -c 1-8)
data_arr[1]=$(date +%Y-%m-%d-%H00 -d "$hh:00:00 $amd 0 hours ago")

while [ "$horas" -lt "$tmax" ]; do
    amd=$(echo "${data_arr[$t]}" | cut -c 1-10)
    hora=$(echo "${data_arr[$t]}" | cut -c 12-13)
    t=$(expr "$t" + 1)
    horas=$(expr "$horas" + "$int_dp")
    data_arr[$t]=$(date +%Y-%m-%d-%H00 -d "$hora:00:00 $amd $int_dp hours")
done
tmax_dp=$t

################################ ESPERA OS DADOS DO GFS #############################################################

verifica_dps
if [ $existe_dp -eq 0 ]; then
    
    DIR_GFS="/scratchout/oper/tempo/externos/Download/FORECAST/GFS_025gr"
    #FCST=072
    FCST='0'"$tmax"
    #wgrib2=/opt/grads/2.0.a9/bin/wgrib2
    wgrib2="/opt/wgrib2"
    
    if [ 0$($wgrib2 -match "UGRD|VGRD|TMP|HGT|RH" -match " mb:|:surface:" $DPS_DIR/gfs.t${edate:8:10}z.pgrb2.0p25.f${FCST}.${edate}.grib2 | wc -l) -lt 157 ] ;then
        echo "Copiando dados do GFS ..."
        sshpass -f .tupass scp "denis.eiras@tupa:${DIR_GFS}/${edate:0:8}/*${edate}*.*" "$DPS_DIR"
    fi

    cont=0 ; n_wait=500
    while [ 0$($wgrib2 -match "UGRD|VGRD|TMP|HGT|RH" -match " mb:|:surface:" $DPS_DIR/gfs.t${edate:8:10}z.pgrb2.0p25.f${FCST}.${edate}.grib2 | wc -l) -lt 157 ] ;do
        echo "Aguardando dados do GFS - ${edate}"
        let cont=$cont+1
        if [ $cont -ge $n_wait ] ; then
            echo "Faltando dados do GFS - ${edate} . Tempo de cópia excedido ! (${n_wait} minutos)"
            exit 1
        else
            sleep 60
        fi
    done
    echo "Dados do GFS copiados - ${edate}"

    ################################ VERIFICA SE OS DADOS DO GFS ESTAO CORRETOS #########################################

    DATAF=$(date -d "${edate:0:8} ${edate:8:10}:00 ${FCST} hours" +"%Y%m%d%H")
    verifica "${edate}" "${DATAF}"
    echo "Dados do GFS corretos - ${edate}"

    echo "Gerando os DPS ..."

    ################################ GERA DPS #########################################

    cd "$DIRexec/src/dprep-chem/geraDP/"
    gfortran -O3 -o geraDP.x geraDP.f90
    cp -p geraDP.x geraBIN.gs geraDP.sh gfs_template_example.ctl "${DPS_DIR}"

    cd "${DPS_DIR}"
    cp "$DIRexec/geraDP.ini.template" .
    ctl_file_name="gfs${edate}.ctl"

    data_ctl=$(date -d "${edate:0:8} ${edate:8:2}:00 000000 hours" +"%H"Z"%d%b%Y")
    cat < gfs_template_example.ctl \
        | sed "s@DATA@${edate}@g" \
        | sed "s@D_CTL@${data_ctl}@g" \
        | sed s@"TDEF"@"$tmax_dp"@g \
        | sed s@"DIR_GFS"@"$DPS_DIR"@g \
        | sed s@"_HH_"@"${edate:8:10}"@g > ${ctl_file_name}
    gribmap -i "./gfs${edate}.ctl"

    # old style
    #./geraDP.sh "./gfs${edate}.ctl" UVEL VVEL TEMP ZGEO UMRL 26 -70 29 250 358 NAO
    
    # new style # using geraDP.ini
    cat < ./geraDP.ini.template \
        | sed "s@<ctl_file_name>@${ctl_file_name}@g" > geraDP.ini
    ./geraDP.sh # using geraDP.ini

    verifica_dps
    if [ $existe_dp -eq -1 ]; then
        'DPS deveriam existir ...saindo'
        exit 1
    fi

    echo "DPs Gerados - ${edate}"

    ################################ GERA DPS RELACS #########################################

    echo "Gerando DPs com química ..."
    
    # ############################# lincenca intel expirada.
    # cd $DIRexec/src/dprep-chem/bin/build
    # make OPT=intel CHEM=RELACS_TUV clean
    # make OPT=intel CHEM=RELACS_TUV
    dprep_exe_name=dprep_RELACS_TUV.exe
    dprep_exe=$DIRexec/src/dprep-chem/bin/$dprep_exe_name
    if [ -f "$dprep_exe" ]
    then
        echo "$dprep_exe found."
    else
        echo "$dprep_exe not found."
        exit 1
    fi

    cd ${DPS_DIR}
    cp $dprep_exe .
    cp $DIRexec/dprep.inp_template .

    cat ./dprep.inp_template \
                | sed s@"<ano>"@"${edate:0:4}"@g \
                | sed s@"<mes>"@"${edate:4:2}"@g \
                | sed s@"<dia>"@"${edate:6:2}"@g \
                | sed s@"<hora>"@"${edate:8:2}"@g \
                | sed s@"<dp_dir>"@"${DPS_DIR}"@g \
                | sed s@"<tmax_dp>"@"${tmax_dp}"@g \
                > ./dprep.inp

    ./${dprep_exe_name}
    rm ./${dprep_exe_name}

    echo "DPs com química ǵerados - ${edate}"

    rm -rf $DPS_DIR/dp20*
    rm -rf $DPS_DIR/gfs.t00z*
    rm -rf $DPS_DIR/gfs025*
    cd $DIRexec
fi  