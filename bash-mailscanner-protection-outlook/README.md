# MailScanner Outlook

>Autor: Agustin Alvarez

>Fecha: 10/04/2024

>Versión: 1.0

>Lenguaje: Bash


## Descripción

Script que permite agregar las IP correspondientes a protection.outlook.com en la base de whitelist de MailScanner, devuelve en su salida en pantalla las IP que se agregan.
Esto ocurre que algunas IP son consideradas como spam por SpamCop (servicio online gratuito de informes de spam por correo electrónico) perteneceientes a Microsoft (Protection.Outlook.Com) bloqueando el ingreso de correos legítimos.
SpamCop considerada esas IP como Spam ya que los spammers abusan del servicio de cloud de Microsoft alquilando virtuales para realizar su campaña. Esas IP pertenecen a un único pool que son asignadas dinámicamente al servicio de correo corporativo de Microsoft.
Mediante un cron se ejecuta peridicamente (cada 30 min) en el server para verificar las IP bloqueadas dentro del mail.log e insertar las novedades en la tabla de whitelist de la base de datos MySQL de MailScanner.
Ls credenciales de MySQL se encuentran guardadas en un archivo aparte dentro del usuario que corre el cron (según recomendación de la documentación técnica de MySQL).

El script requiere de privilegios para ser ejecutado.
Puede ser ejecutado de forma manual sin nngun tipo de interferencia.

## Changelog
10/4/2024	Release incial