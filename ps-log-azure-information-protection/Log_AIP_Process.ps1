# Ruta del archivo de entrada y salida
$archivoEntrada = "AIP_Log.txt"
$archivoSalida = "AIP_Log_Process.csv"

# Diccionario de etiquetas de sensibilidad
$etiquetas = @{
"a478f1c7-4ced-489f-9c25-1189acd1579d" = "Public"
"89466092-a22a-4827-9d72-d00494a09567" = "Internal Use"
"aa401f51-9910-48e5-911d-965229c964b7" = "Confidential"
"c8865157-e14f-48c3-bede-d8da518acad7" = "Highly Confidential"
}

# Lista para resultados
$resultados = @()

$contador = 0

# Procesar cada línea del archivo
Get-Content $archivoEntrada | ForEach-Object {
    $contador++
    try {
        $data = $_ | ConvertFrom-Json
        $labelId = $data.SensitivityLabelEventData.SensitivityLabelId

        $obj = [PSCustomObject]@{
            UserId               = $data.UserId
            ObjectId             = $data.ObjectId
            SensitivityLabelId   = $labelId
            SensitivityLabelName = $etiquetas[$labelId]  # Buscar texto asociado
            CreationTime         = $data.CreationTime
        }

        $resultados += $obj
    } catch {
        Write-Warning "Línea $contador con JSON inválido, ignorada."
    }
}

# Exportar a CSV
$resultados | Export-Csv -Path $archivoSalida -NoTypeInformation -Encoding UTF8

Write-Host "Exportación completada: $archivoSalida"
