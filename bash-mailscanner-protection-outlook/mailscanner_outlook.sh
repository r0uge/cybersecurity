#!/bin/bash

# Script para adicionar las IP correspondientes a Protection.Outlook.Com  ya que Mailwatch no aceptar comodines para procesar redes
# A partir del log detecta las direcciones nuevas y las inserta en la BD de Mailscanner/Mailwatch
# Autor: Agustin Alvarez
# Fecha de ultima modificacion: 10/04/2024

#Variables
#--------
# Archivo mail.log
MAIL_LOG="/var/log/mail.log"
# Nombre de la base de datos MySQL
DB_NAME="mailscanner"
# Usuario y contraseña de MySQL
DB_USER="mailwatch"
DB_PASS=""
# Consulta SQL para obtener la lista de direcciones en whitelist
SQL_QUERY="SELECT from_address FROM whitelist;"

# Obtener las direcciones de correo del archivo mail.log
grep protection.outlook.com $MAIL_LOG | grep blocked | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u > /tmp/mail_log_addresses.txt

# Consultar las direcciones en la tabla whitelist de la base de datos
#mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -se "$SQL_QUERY"  > /tmp/db_addresses.txt
mysql --login-path=local -u $DB_USER -D $DB_NAME -se "$SQL_QUERY"  > /tmp/db_addresses.txt

# Comparar las direcciones del archivo mail.log con las de la base de datos
DIFF=$(comm -13 <(sort /tmp/db_addresses.txt) <(sort /tmp/mail_log_addresses.txt))
#DIFF=$(diff /tmp/mail_log_addresses.txt /tmp/db_addresses.txt | grep "^<" | sed -e 's/^<//' -e 's/^[[:space:]]*//')

echo $DIFF

if [ -z "$DIFF" ]; then
   echo "No hay nuevas IP";
   exit;
fi


# Iterar sobre las direcciones que están en mail.log pero no en la base de datos
while IFS= read -r line; do
    # Agregar la dirección a la tabla whitelist en la base de datos
    #mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "INSERT INTO whitelist (to_address,from_address) VALUES ('default','$line');"
    mysql --login-path=local -u $DB_USER -D $DB_NAME -e "INSERT INTO whitelist (to_address,from_address) VALUES ('default','$line');"

done <<< "$DIFF"

# Eliminar archivos temporales
rm /tmp/mail_log_addresses.txt
rm /tmp/db_addresses.txt

# Contar la cantidad de direcciones IP insertadas en la base de datos
COUNT=$(echo "$DIFF" | wc -l)
echo "Se insertaron $COUNT direcciones IP en la base de datos."

echo "Proceso completado."
