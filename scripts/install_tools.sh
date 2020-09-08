#Prgrams to be installed by Linux Packages
# - grads
# - gcc & gfortran
# - build-essential
# - wget
# - mpich

# By the moment we cannot use aptitude because this method is not portable and usable in any linux
# if [ $EUID -ne 0 ]; then
#     sudo apt-get update && sudo apt-get -y install wget grads gcc gfortran build-essential mpich
# else
#     apt-get update && apt-get -y install wget grads gcc gfortran build-essential mpich
# fi

# if [ ! -d tools ]; then
# 	mkdir tools
# fi

rootAbsoluteFolder=`pwd`
toolsAbsoluteFolder=${rootAbsoluteFolder}/tools

#wgrib2
if [ ! -f /usr/local/bin/wgrib2 ]; then
    if [ $EUID -ne 0 ]; then
        sudo rm /usr/local/bin/wgrib2
    else
        rm /usr/local/bin/wgrib2
    fi
    rm -r ${rootAbsoluteFolder}/tools/grib2
    wget -nc -P ${toolsAbsoluteFolder} ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz
    tar -xzvf ${rootAbsoluteFolder}/tools/wgrib2.tgz -C ${toolsAbsoluteFolder}
    rm ${rootAbsoluteFolder}/tools/wgrib2.tgz
    cd ${toolsAbsoluteFolder}/grib2
    export CC=gcc
    export FC=gfortran
    make
    if [ $EUID -ne 0 ]; then
        sudo ln -s ${toolsAbsoluteFolder}/grib2/wgrib2/wgrib2 /usr/local/bin/wgrib2
    else
        ln -s ${toolsAbsoluteFolder}/grib2/wgrib2/wgrib2 /usr/local/bin/wgrib2
    fi
fi

#g2ctl
if [ ! -f /usr/local/bin/g2ctl ]; then
    if [ $EUID -ne 0 ]; then
        sudo rm /usr/local/bin/g2ctl
    else
        rm /usr/local/bin/g2ctl
    fi
    rm ${rootAbsoluteFolder}/tools/g2ctl
    wget -nc -P ${toolsAbsoluteFolder} ftp://ftp.cpc.ncep.noaa.gov/wd51we/g2ctl/g2ctl
    chmod +x g2ctl

    if [ $EUID -ne 0 ]; then
        sudo ln -s ${toolsAbsoluteFolder}/g2ctl /usr/local/bin/g2ctl
    else
        ln -s ${toolsAbsoluteFolder}/g2ctl /usr/local/bin/g2ctl
    fi
fi

#We Use a Modified Version of Brams To Avoid Problems on Root Folder
#brams
if [ ! -f /usr/local/bin/brams ]; then
    if [ $EUID -ne 0 ]; then
        sudo rm /usr/local/bin/brams
    else
        rm /usr/local/bin/brams
    fi
    wget -nc -P ${toolsAbsoluteFolder} http://ftp1.cptec.inpe.br/brams/BRAMS/brams-5.3-src.tgz
    mkdir ${toolsAbsoluteFolder}/brams_src
    mkdir ${toolsAbsoluteFolder}/brams-5.3
    tar -zxvf ${toolsAbsoluteFolder}/brams-5.3-src.tgz -C ${toolsAbsoluteFolder}/brams_src
    
    #Fix Problems on Brams Code (BRAMS5.3) With GFortran and GCC
    sed -i 's/STOP\x27init_top\x27/STOP \x27init_top\x27/' ${toolsAbsoluteFolder}/brams_src/src/jules/LIB/SOURCE/SUBROUTINES/INITIALISATION/init_top.f90
    sed -i 's/integer,  dimension (12) :: seed/integer,  dimension (33) :: seed/' ${toolsAbsoluteFolder}/brams_src/src/brams/cuparm/module_cu_g3.f90

    cd ${toolsAbsoluteFolder}/brams_src/build
    ./configure -program-prefix=BRAMS -prefix=${toolsAbsoluteFolder}/brams-5.3 -enable-jules -with-chem=RELACS_TUV -with-aer=SIMPLE -with-fpcomp=/usr/bin/mpif90 -with-cpcomp=/usr/bin/mpicc -with-fcomp=gfortran -with-ccomp=gcc
    make
    make install
    rm -r ${toolsAbsoluteFolder}/brams_src
    if [ $EUID -ne 0 ]; then
        sudo ln -s ${toolsAbsoluteFolder}/brams-5.3/bin/brams-5.3 /usr/local/bin/brams
    else
        ln -s ${toolsAbsoluteFolder}/brams-5.3/bin/brams-5.3 /usr/local/bin/brams
    fi
fi

# geraDP
if [ ! -f ${toolsAbsoluteFolder}/geraDP/geraDP.x ]; then
    wget -nc -P ${toolsAbsoluteFolder} http://ftp.cptec.inpe.br/brams/DPREP-CHEM_GERADP/DPREP-CHEM_GERADP-5.1.0.tgz
    tar -zxvf ${toolsAbsoluteFolder}/DPREP-CHEM_GERADP-5.1.0.tgz -C ${toolsAbsoluteFolder} DPREP-CHEM-5.1.0/geraDP
    mv ${toolsAbsoluteFolder}/DPREP-CHEM-5.1.0/geraDP ${toolsAbsoluteFolder}/geraDP
    rm -r ${toolsAbsoluteFolder}/DPREP-CHEM-5.1.0
    rm -f ${toolsAbsoluteFolder}/DPREP-CHEM_GERADP-5.1.0.tgz
    gfortran ${toolsAbsoluteFolder}/geraDP/geraDP.f90 -o ${toolsAbsoluteFolder}/geraDP/geraDP.x
fi