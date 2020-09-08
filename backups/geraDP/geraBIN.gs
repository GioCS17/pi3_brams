*
* ==============================================================================
* geraDP
* ==============================================================================
*
* This script is part of geraDP program, its used in geraDP.sh script.
* It generates the grads files for reading at geraDP.f90
*
* Revisions / authors:
* ====================
* 2009-04-01 - Demerval S. Moreira (demervalsm@gmail.com) - Automatic level for UR
*
* 2018-11-12 - Denis Eiras (denis.eiras@inpe.br) - Max Level and max level for variables must be
* informed in geraDP.ini, if desired to restrict the levels.
*

function main(args)
nome=subwrd(args,1)
nX=subwrd(args,2); loni=subwrd(args,3); intX=subwrd(args,4)
nY=subwrd(args,5); lati=subwrd(args,6); intY=subwrd(args,7)
nlev=subwrd(args,8);nt=subwrd(args,9);def=subwrd(args,10)
linear=subwrd(args,11);to_f90=subwrd(args,12);nc=subwrd(args,13);u=subwrd(args,14)
v=subwrd(args,15);temp=subwrd(args,16);geo=subwrd(args,17)
ur=subwrd(args,18);zmax=subwrd(args,19);lat2i=subwrd(args,20)
lat2f=subwrd(args,21);lon2i=subwrd(args,22);lon2f=subwrd(args,23)
u_z_limit=subwrd(args,24);u_value=subwrd(args,25)
v_z_limit=subwrd(args,26);v_value=subwrd(args,27)
temp_z_limit=subwrd(args,28);temp_value=subwrd(args,29)
geo_z_limit=subwrd(args,30);geo_value=subwrd(args,31)
ur_z_limit=subwrd(args,32);ur_value=subwrd(args,33)

say "***************"
say 'ctl=   'nome
say 'nx=    'nX
say 'loni=  'loni
say 'intX=  'intX
say 'nY=    'nY
say 'lati=  'lati
say 'intY=  'intY
say 'nlev=  'nlev
say 'nt=    'nt
say 'def=   'def
say 'zmax=  'zmax

say 'linear='linear
say 'u_z_limit = 'u_z_limit
say 'u_value = 'u_value
say 'v_z_limit = 'v_z_limit
say 'v_value = 'v_value
say 'temp_z_limit = 'temp_z_limit
say 'temp_value = 'temp_value
say 'geo_z_limit = 'geo_z_limit
say 'geo_value = 'geo_value
say 'ur_z_limit = 'ur_z_limit
say 'ur_value = 'ur_value

if (u!='')
   say 'u     ='u
   say 'v     ='v
   say 'temp  ='temp
   say 'geo   ='geo
   say 'ur    ='ur
   say 'zmax  ='zmax
   say 'lat2i ='lat2i
   say 'lat2f ='lat2f
   say 'lon2i ='lon2i
   say 'lon2f ='lon2f
endif
say 'to_f90='to_f90
say

if (to_f90="S")
  if (nc='nc')
     'sdfopen 'nome''
  else
    'open 'nome''
  endif
  z=1
  lev=""
  while (z<=nlev)
    'set z 'z''
    'q dims'
    vlev=sublin(result,4);vlev=subwrd(vlev,6)
    lev=lev" "vlev
    z=z+1
  endwhile
  dims=nlev' 'nX' 'nY' 'loni' 'lati' 'intX' 'intY' '
  lixo=write(dims.txt,dims)
  lixo=write(dims.txt,lev)
  lixo=write(dims.txt,nt)
  t=1
  while (t<=nt)
    'set t 't''
    'q time'
     tempo=subwrd(result,3)
     hora=substr(tempo,1,2)
     dia=substr(tempo,4,2)
     mes=substr(tempo,6,3)
     ano=substr(tempo,9,4)

     if (mes=JAN); mesC=01; endif
     if (mes=FEB); mesC=02; endif
     if (mes=MAR); mesC=03; endif
     if (mes=APR); mesC=04; endif
     if (mes=MAY); mesC=05; endif
     if (mes=JUN); mesC=06; endif
     if (mes=JUL); mesC=07; endif
     if (mes=AUG); mesC=08; endif
     if (mes=SEP); mesC=09; endif
     if (mes=OCT); mesC=10; endif
     if (mes=NOV); mesC=11; endif
     if (mes=DEC); mesC=12; endif

     lixo=write(dims.txt,'dp'ano'-'mesC'-'dia'-'hora'00')
     t=t+1
   endwhile
   lixo=close(dims.txt)
  'quit'
endif


if (linear="e" | linear="E");intY=intX;endif  ;* se ydef for em levels
if (lat2i=-999);lat2i="";endif
if (lat2f=-999);lat2f="";endif
if (lon2i=-999);lon2i="";endif
if (lon2i=-999);lon2i="";endif
faz=zmax
if (nc='nc')
   'sdfopen 'nome''
else
  'open 'nome''
endif
'set mpdset mres'
'set map 1 1 6'
'q file'
say result

if (faz="")
  say
  prompt "Enter the variable name <zonal wind> (ex: u)=>"
  pull u
* u=uvel
  say
  prompt "Enter the variable name <meridional wind> (ex: v)=>"
  pull v
* v=vvel
  say
  prompt "Enter the variable name <kelvin temperature> (ex: tempK or temp+273.16)=>"
  pull temp
* temp=temp
  say
  prompt "Enter the variable name <geopotential> (ex: geo)=>"
  pull geo
* geo=zgeo
  say
  prompt "Enter the variable name <relative humidy in %> (ex: ur or ur*100)=>"
  pull ur
* ur="umrl*100"
*  say
*  prompt "Entre com o numero de niveis da umidare relativa (ex: 8)=>"
*  pull zmax
* zmax=8
  say
endif

u=subwrd(u,1); v=subwrd(v,1); temp=subwrd(temp,1); geo=subwrd(geo,1);  ur=subwrd(ur,1); zmax=subwrd(zmax,1)

*say nX"   "loni"   "intX"   "nY"   "lati"   "intY"   "nlev"   "nt"   "u"   "v"   "temp"   "geo"   "ur

xi=1;xf=nX
yi=1;yf=nY
'd 'u''
say
if (faz="")
  prompt "Enter the initial and final latitude (ex: -80 20) or press <Enter> to continue=>"
  pull resp
  lat2i=subwrd(resp,1); lat2f=subwrd(resp,2);
endif
if (lat2i!="")
  'set lat 'lat2i' 'lat2f''
  'q dims'
  a=sublin(result,3);a=subwrd(a,11)
  i=1;b=""
  while (i<=5)
    if (substr(a,i,1)!=".");b=b''substr(a,i,1);else; i=999;endif
    i=i+1
  endwhile
  if (b<0);say "yi is negative,  quitting..."; 'quit'; endif
  if (b<1);b=1; endif
  yi=b
  'q dims'
  a=sublin(result,3);a=subwrd(a,13)
  i=1;b=""
  while (i<=5)
    if (substr(a,i,1)!=".");b=b''substr(a,i,1);else; i=999;endif
    i=i+1
  endwhile
  yf=b
  'set y 'yi' 'yf''
  'clear'
  'd 'u''
  if (faz="")
    prompt "Enter the initial and final longitude (ex: 250 350) or press <Enter> to continue=>"
    pull resp
    lon2i=subwrd(resp,1); lon2f=subwrd(resp,2);
  endif
  if (lon2i!="")
    'set lon 'lon2i' 'lon2f''
    'q dims'
    a=sublin(result,2);a=subwrd(a,11)
    i=1;b=""
    while (i<=5)
    if (substr(a,i,1)!=".");b=b''substr(a,i,1);else; i=999;endif
    i=i+1
    endwhile
    if (b<0);say "xi is negative, quitting..."; 'quit'; endif
    if (b<1);b=1; endif
    xi=b
    'q dims'
    a=sublin(result,2);a=subwrd(a,13)
    i=1;b=""
    while (i<=5)
      if (substr(a,i,1)!=".");b=b''substr(a,i,1);else; i=999;endif
      i=i+1
    endwhile
    xf=b
    'set x 'xi' 'xf''
    'clear'
    'd 'u''
  endif
endif

***** checking levels used... *****
'q ctlinfo'
fim=0;cont=1
nlev=999
while (fim<5 & cont<200)
  linha=sublin(result,cont)
  var=subwrd(linha,1)
* restricts to the lower level
  if (var=u | var=v | var=temp | var"+273.16"=temp | var=geo | var=ur | var"*100"=ur )
     if (nlev>subwrd(linha,2)); nlev=subwrd(linha,2); endif
     fim=fim+1
  endif
  cont=cont+1
endwhile

if (nlev>zmax)
    say 'Number of levels ='nlev' limited to z_max_level informed in geraDP.ini = 'zmax
    nlev=zmax
endif

say

'set x 'xi' 'xf''
'set y 'yi' 'yf''
'q dims'
lon=sublin(result,2);loni=subwrd(lon,6);xi=subwrd(lon,11);xf=subwrd(lon,13)
nX=(xf-xi)+1
lat=sublin(result,3);lati=subwrd(lat,6);yi=subwrd(lat,11);yf=subwrd(lat,13)
nY=(yf-yi)+1

z=1
lev=""
while (z<=nlev)
  'set z 'z''
  'q dims'
  vlev=sublin(result,4);vlev=subwrd(vlev,6)
  lev=lev" "vlev
  z=z+1
endwhile

t=1
nt2=nt
ts=""

say '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 1'
while (t<=nt2)
  'clear'
  'set t 't''
  'set z 1'
  'd 'u''
  ne=subwrd(result,6)
  if (ne!="undefined");ts=ts" "t;else; nt=nt-1;endif
  t=t+1
endwhile

dims=nlev' 'nX' 'nY' 'loni' 'lati' 'intX' 'intY' '
lixo=write(dims.txt,dims)
lixo=write(dims.txt,lev)
lixo=write(dims.txt,nt)

'set stat on'
'set gxout fwrite'
'set fwrite to_dp.gra'
t=1
while (t<=nt)
  say t' / 'nt
  tempo=subwrd(ts,t)
  'set t 'tempo''
  'q time'
   tempo=subwrd(result,3)
   hora=substr(tempo,1,2)
   dia=substr(tempo,4,2)
   mes=substr(tempo,6,3)
   ano=substr(tempo,9,4)

   if (mes=JAN); mesC=01; endif
   if (mes=FEB); mesC=02; endif
   if (mes=MAR); mesC=03; endif
   if (mes=APR); mesC=04; endif
   if (mes=MAY); mesC=05; endif
   if (mes=JUN); mesC=06; endif
   if (mes=JUL); mesC=07; endif
   if (mes=AUG); mesC=08; endif
   if (mes=SEP); mesC=09; endif
   if (mes=OCT); mesC=10; endif
   if (mes=NOV); mesC=11; endif
   if (mes=DEC); mesC=12; endif

   lixo=write(dims.txt,'dp'ano'-'mesC'-'dia'-'hora'00')

***** U *******
  z=1
  while (z<=nlev)
    'clear'
    'set z 'z''
    if (z > u_z_limit)
      'd 'u'-'u'+'u_value
    else
      'd 'u''
    endif

    indef=sublin(result,7); indef=subwrd(indef,4)

    if (indef!=0)
      say 'ERROR! encounterd undef value. var='u' z='z
      'quit'
    endif

    z=z+1
  endwhile
***** V *******
  z=1
  while (z<=nlev)
    'clear'
    'set z 'z''
    if (z > v_z_limit)
        'd 'v'-'v'+'v_value
    else
        'd 'v''
    endif

    indef=sublin(result,7); indef=subwrd(indef,4)
    if (indef!=0)
      say 'ERROR! encounterd undef value. var='v' z='z
      'quit'
    endif

    z=z+1
  endwhile
***** TEMPK *******
  z=1
  while (z<=nlev)
    'clear'
    'set z 'z''
    if (z > temp_z_limit)
        'd 'temp'-'temp'+'temp_value
    else
        'd 'temp''
    endif

    indef=sublin(result,7); indef=subwrd(indef,4)
    if (indef!=0)
      say 'ERROR! encounterd undef value. var='temp' z='z
      'quit'
    endif

    z=z+1
  endwhile
***** GEO *******
  z=1
  while (z<=nlev)
    'clear'
    'set z 'z''
    if (z > geo_z_limit)
        'd 'geo'-'geo'+'geo_value
    else
        'd 'geo''
    endif

    indef=sublin(result,7); indef=subwrd(indef,4)
    if (indef!=0)
      say 'ERROR! encounterd undef value. var='geo' z='z
      'quit'
    endif

    z=z+1
  endwhile
***** UR em frac *******
  z=1
  while (z<=nlev)
    'clear'
    'set z 'z''
    if (z > ur_z_limit)
        'd 'ur'-'ur'+'ur_value
    else
        'd 'ur''
    endif

    indef=sublin(result,7); indef=subwrd(indef,4)
    if (indef!=0)
    say 'ERROR! encounterd undef value. var='ur' z='z
        'quit'
    endif
    z=z+1
  endwhile

*  Read surface fields
*O campo de superficie serah escrito constante igual a zero.

  t=t+1
endwhile
'disable fwrite'

lixo=close(dims.txt)

'quit'