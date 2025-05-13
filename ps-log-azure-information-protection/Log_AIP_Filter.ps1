#Filtra el log de AIP
#Toma la entrada y filtra que contencta SensitivityLabelId y ApplicationName y que no contengan SVCAIPFS@tenaris.com.
#Debido que tengo version PS5 el Select-String carece de -Raw pro lo que que se tiene que formatear la salida con ForEachObject

Select-String -Path .\*.txt -Pattern "SensitivityLabelId" | Select-String -Path -Pattern "ApplicationName" | Select-String -Path -Pattern "SVCAIPFS@tenaris.com" -NotMatch | ForEach-Object { $_.Line } | Out-File -FilePath C:\Users\T23952\Documents\AIP_Log.txt