# Scripts para Administrar BRAMS

## Requisitos

1. [Docker](https://docs.docker.com/install/)
2. [Docker Compose](https://docs.docker.com/compose/)
3. [Grads](http://cola.gmu.edu/grads/)

## Ejecución

Los pasos para iniciar los servicios para realizar las predicciones con BRAMS son:


1. Si estás dentro de un entorno con sistema operativo Linux o escritorio X11, abrir la terminal y ejecutar `xauth list` y saldrá un resultado parecido a este.

    `<user>/unix:  MIT-MAGIC-COOKIE-1  d4adc1938cc18b61b9a84dc210ac5371`
    
    copiar el número después de la palabra `MIT-MAGIC-COOKIE-1` y reemplazarlo por el valor de `MAGIC_NUMBER` en el archivo `docker-compose.yml`

2. Ejecutar el comando `docker-compose up -d` dentro del repositorio. Si las imágenes no han sido construidas, esperar sus construcción y posterior ejecución. 

3. Hacer uso de BRABU, si se necesita sino cerrar. De preferencia guardar en la ruta **/scripts/(NombreDelRAMSIN)**

4. Conectarse a la primer contenedor para realizar la descarga de datos y preparar datos para BRAMS con el comando `docker attach brams-scripts_prepare-data_1` y ejecutar el comando `./prepare_data.sh 2019122600 72 0p25` donde el primer parámetro del script es la fecha y hora que va a descargarse, el segundo, la cantidad de horas a descargar y el tercero la resolución del GFS a descargar 

5. Conectarse al segundo contenedor para realizar la predicción con el comando `docker attach brams-scripts_brams_1` y ejecutar el comando `./run_brams.sh 2019122600 MAKESFC` donde el primer parámetro del script es la fecha y hora que ya se descargó y el segundo la acción, en este caso `MAKESFC`, que permitirá obtener las variables iniciales de superficie

6. Dentro del mismo contenedor ejecutar el comando `./run_brams.sh 2019122600 MAKEVFILE` para obtener las variables iniciales y el comando `./run_brams.sh 2019122600 INITIAL` para realizar la predicción

7. Conectarse al tercer contenedor para interpretar los datos con el comando `docker attach brams-scripts_results_1` y dirigirse a la ruta **/data/dataout/POSPROCESS** y ejecutar el comando `grads`, luego dentro de **grads** `open <nombre-archivo.ctl>`, dónde el nombre del archivo corresponde a la hora que se desea visualizar en grads.

8. Exportar la imagen PNG de **grads** a la carpeta **/data/dataout**

> TODO

- Crear un archivo **.ctl** que permita la lectura de todos los archivos de posprocesamiento de brams sin necesidad de abrir uno cada hora

- Conectar la GUI de **grads** a el host externo desde el contenedor de docker con nombre `brams-scripts_results_1`