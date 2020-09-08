#!/bin/bash

# -*- ENCODING:UFT-8 -*-
#""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#...._      _  _        _  _   __   _   _    _             #
#...|-| |_| | |_| |\/| |-| | |  /_ |-| |_ | |_| |\/....    #
#      ___   __   __   _  _   __                           #
#      |__) |__) |__| | \/ | |__                           #
#.... _|__) |  \ |  | |    |  __|................          #
#                                                          #
#""""""""""""""""""""""""""""""""""""""""""""""""""""""""" #

##...===============================================================================
##...Este script no es copia de ningun otro, su algoritmo es original y su código.....
##...Este Script se realizado con la finalidad de automatizar la ejecucion del BRAMS en el 
##...Laboratorio de Calculo en la Universidad Nacional de Trujillo, de tal manera que 
##...pueda actualizar los datos del CPTEC y actualizar las simulaciones del clima
##...Procesamiento y Pos procesamiento.
##.........Elaborado: Luis Jhony Caucha Morales 
##.........email: ljhony82@yhoo.com - ljcaucham@untumbes.edu.pe    cel: 950499160 
##.........estudiante del Doctorado en Matemáticas de la escuela de PostGrado de la Universidad Nacional de Trujillo
##.........Fecha: 05/03/2015
##.....si lo Utilizan y lo modifican por favor no olvidar hacer referencia del autor inicial
##...Muchas Gracias
##...================================================================================

##crear comprobar y crear carpetas
Ano=`date +%Y`
##echo $Ano
Mes=`date +%Y%m`

Dia=`date +%Y%m%d`
DiaAnt=`date +%Y%m%d -d '-1 day'`
DiaPost=`date +%Y%m%d -d '+1 day'`
#echo $DiaAnt
#echo $Dia
#echo $DiaPost
CARPETA=$Ano
if [ ! -d $CARPETA ]; then
	mkdir $CARPETA
#	echo "todo dicho"
else
	carpMes=$CARPETA/$Mes/
    	mkdir $carpMes
#	echo "Todo creado"
fi
carpDia=$carpMes/$Dia
mkdir $carpDia

##sleep 3
###descargar archivos del cptec

ruta=$HOME/ftu_2019/dprep/ejemplo
##rutaElim=$HOME/BRAMS/ftu


cd $ruta


#cd A
#mv *.vfm $carpDia
#mv *.txt $carpDia
#cd ..
#rm -r H
#rm -r data
#rm  -r ivar
#mkdir H
#mkdir data
#mkdir ivar
#cd ..
#cd $ruta

## wget descargar archivos

webdir="ftp://ftp1.cptec.inpe.br/modelos/io/tempo/global/T126L28/"
hora=`date +%H`
if [ $hora -lt 24 ] 
then
	rm -f  dp*
	rm -f GAMRAMS*.*

	webDirDia="$Dia"00""
	webDirDiaAnt="$DiaAnt"00""
		d1="00"
       		arcCtl=GAMRAMS$webDirDia$Dia$d1"P".icn.TQ0126L028.ctl
 		wget  $webdir$webDirDia/$arcCtl
 		arcGmp=GAMRAMS$webDirDia$Dia$d1"P".icn.TQ0126L028.gmp
		wget  $webdir$webDirDia/$arcGmp
		arcGrb=GAMRAMS$webDirDia$Dia$d1"P".icn.TQ0126L028.grb
 		wget  ${WGET_opt} $webdir$webDirDia/$arcGrb
		for i in `seq 1 3 `
	        do 

		d11=`expr $i \* 6`
		if [ $d11 -eq 6 ] 
		then
     			d1="0$d11"
         		arcCtl=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.ctl
	 		wget  $webdir$webDirDia/$arcCtl
	 		arcGmp=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.gmp
	 		wget  $webdir$webDirDia/$arcGmp
			arcGrb=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.grb
	 		wget  ${WGET_opt} $webdir$webDirDia/$arcGrb
		else
			d1=$d11
			arcCtl=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.ctl
        		wget   $webdir$webDirDia/$arcCtl
	 		arcGmp=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.gmp
			wget $webdir$webDirDia/$arcGmp
			arcGrb=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.grb
 	 		wget $webdir$webDirDia/$arcGrb
		fi
 	done

    	        arcCtlo=GAMRAMS$webDirDia$DiaPost"00P".fct.TQ0126L028.ctl
		        wget   $webdir$webDirDia/$arcCtlo
	       arcGmpo=GAMRAMS$webDirDia$DiaPost"00P".fct.TQ0126L028.gmp
   	       wget $webdir$webDirDia/$arcGmpo
		      arcGrbo=GAMRAMS$webDirDia$DiaPost"00P".fct.TQ0126L028.grb
		       wget $webdir$webDirDia/$arcGrbo
	
       webDirDiaNew=$webDirDia
 else

  	webDirDia="$Dia"12""
	webDirDiaAnt="$DiaAnt"12""
	for i in `seq 1 3 `
	do 
		d11=`expr $i \* 6`
		if [ $d11 -eq 12 ] 
		then
			d1=$d11
			rm dp*$d1"00"
	                rm GAMRAMS*$d1.*


        		arcCtl=GAMRAMS$webDirDia$Dia$d1"P".inc.TQ0126L028.ctl
	 	         echo $webdir$webDirDia/$arcCtl
	 		arcGmp=GAMRAMS$webDirDia$Dia$d1"P".inc.TQ0126L028.gmp
	 		wget $webdir$webDirDia/$arcGmp
			arcGrb=GAMRAMS$webDirDia$Dia$d1"P".inc.TQ0126L028.grb
	 		wget $webdir$webDirDia/$arcGrb
		else
			d1=$d11
			rm dp*$d1"00"
	                rm GAMRAMS*$d1.*

			arcCtl=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.ctl
        		wget   $webdir$webDirDia/$arcCtl
   	 		arcGmp=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.gmp
			wget $webdir$webDirDia/$arcGmp
			arcGrb=GAMRAMS$webDirDia$Dia$d1"P".fct.TQ0126L028.grb
  	 		wget $webdir$webDirDia/$arcGrb
                      
         	        arcCtlo=GAMRAMS$webDirDia$DiaPost"00P".fct.TQ0126L028.ctl
		        wget   $webdir$webDirDia/$arcCtlo
   	       arcGmpo=GAMRAMS$webDirDia$DiaPost"00P".fct.TQ0126L028.gmp
    	       wget $webdir$webDirDia/$arcGmpo
		      arcGrbo=GAMRAMS$webDirDia$DiaPost"00P".fct.TQ0126L028.grb
		       wget $webdir$webDirDia/$arcGrbo
		fi

  	done
	webDirDiaNew=$webDirDia
fi

./grib2dp

#Mm=`date +%m`
#Dd=`date +%d`


##ssh brams@192.168.1.2 
##cd Kepler
#sed -i '20,22d' RAMSIN-oar-model
#sed -i 's/!Startofsimulation/!Startofsimulation\nIMONTH1\='$Mm',\n IDATE1\='$Dd',\n IYEAR1='$Ano',/g' RAMSIN-oar-model

#sshpass -p 'brams' scp dp* brams@192.168.1.2:~/Kepler/input-data/membro2/dprep/
#sshpass -p 'brams' scp RAMSIN-oar-model  brams@192.168.1.2:~/Kepler/

##Mm=`date +%m`
### echo $Mm
### Dd=`date +%d`
###echo $Dd
## #sleep 6
###echo $Ano
##./runBRAMS.sh $Mm $Dd $Ano

exit
