# Script LogParser

Es un script para poder procesar un conjunto de archivos CSV mediante la herramienta [LogParser](https://www.microsoft.com/en-us/download/details.aspx?id=24659), consolidando el resultado en un nuevo archivo (y unico) CSV.


## Funcionalidades:

 - Backup del archivo a existente 
 - Calcula la diferencia en Mb entre el backup y el nuevo archivo 
 - Generación de un log de operaciones con fecha y hora, cantidad de registros procesados y tiempo de ejecución

## Desafios

 - Resolver el manejo de overflow de 32 bits en las variables numericas
    para el calculo de los tamaños
 - Resolver la conversion mostrando un truncamiento de dos decimales     
 - Resolver mostrar correctamente los caracteres especiales como acentos y ñ (comando ***chcp***)  
 - Realizarlo exclusivamente en Batch (por un extraño motivo no me   permitían usar PowerShell)
