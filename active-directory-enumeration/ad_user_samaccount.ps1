#Permite obtener el samAccount desde el UserPrincipalName, que es el correo en este caso
Get-ADUser -Filter "UserPrincipalName -eq 'user_xxxx'" -Properties SamAccountName | Select-Object -expandproperty SamAccountName
