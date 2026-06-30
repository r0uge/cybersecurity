# Fortinet VPN Report

>Autor: Agustin Alvarez

>Fecha: 31/05/2024

>Versión: 1.0

>Lenguaje: Powershell


## Descripción

Script para formatear y correlacionar el log de Fortinet (VPN) obteniendo un CSV y una tabla a la salida con la duración de las sesiones, IP Remota que se conecto, IP asignada en la red local, fecha y hora de inicio y fin.
La ubicación de la salida del CSV se realiza en la misma carpeta donde se enceuntra el script.
Para obtener el log dentro del Fortinet es neceserio ir a:

>	Log & Report -> System Events -> Filtar por usuario y por Message seleccionando SSL tunnel shutdown, SSL tunnel established

El script se encuentra preparado solo para procesar un unico usuario por log
Emplea el campo tunnelid para correlacionar los eventos de inicio y fin de sesión
Considerar que el script lee el archivo de log desde el final hasta su inicio (desde el evento mas antiguo al mas reciente)

Explicación de cada campo:
StartTime: Fecha y Hora de inicio de la VPN (desde que estableció el tunel)
EndTime: Fecha y Hora de fin de la VPN (fin del tunel establecido)
Duration: Expresado en hs, diferencia entre EndTime y StartTime
RemoteIP: IP publica del usuario desde donde se conecto a la VPN 
TunnelIP: IP asignada al establecer el tunel de VPN (perteneciente a la red interna)
TunnelID: Identificador del tunel VPN que le asigna Fortinet

## Requerimientos
Especificar el archivo y ruta del log de Fortinet en la variable $logFilePath


## Changelog
31/5/2024	Release incial