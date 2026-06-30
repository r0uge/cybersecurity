# -----------------------------------------------------------------------------
# Nombre: Fortinet VPN Report
# Autor: Agustin Alvarez
# Descripcion: Script para formatear y correlacionar el log de Fortinet (VPN) obteniendo un CSV y una tabla a la salida con la duración de las sesiones, IP Remota que se conecto, IP asignada en la red local, fecha y hora de inicio y fin.
# Requerimientos: Especificar el archivo y ruta del log de Fortinet en la variable $logFilePath
# Versión: 1.0 (30/05/2024)
# -----------------------------------------------------------------------------

# Definir el archivo de log y el archivo CSV de salida
$logFilePath = "R:\fortinet.log"
$outputCsvPath = Join-Path -Path (Get-Location) -ChildPath ((Get-Date).AddDays(-1).ToString("yyyy-MM-dd") + "-FortinetVPN.csv")

# Leer el log y procesar las entradas
$logs = Get-Content $logFilePath


# Invertir el orden de las líneas
$logs = [System.Collections.ArrayList]::new($logs)
$logs.Reverse()

# Almacenar los eventos de túneles VPN
$tunnels = @{}

# Procesar el log línea por línea
foreach ($line in $logs) {
    if ($line -match 'tunneltype="ssl-tunnel"') {
        if ($line -match 'action="tunnel-up"') {
            $tunnelid = if ($line -match 'tunnelid=(\d+)') { $matches[1].Trim() }
            $date = if ($line -match 'date=(\d{4}-\d{2}-\d{2})') { $matches[1] }
            $time = if ($line -match 'time=(\d{2}:\d{2}:\d{2})') { $matches[1] }
            $remip = if ($line -match 'remip=([\d.]+)') { $matches[1] }
            $tunnelip = if ($line -match 'tunnelip=([\d.]+)') { $matches[1] }
            $user = if ($line -match 'user="([^"]+)"') { $matches[1] }
            $startTime = [datetime]::ParseExact("$date $time", "yyyy-MM-dd HH:mm:ss", $null)
            
            $tunnels[$tunnelid] = [PSCustomObject]@{
                User      = $user
                StartTime = $startTime
                EndTime   = $null
                Duration  = $null
                RemoteIP  = $remip
                TunnelIP  = $tunnelip
                TunnelID  = $tunnelid
            }
        }
        elseif ($line -match 'action="tunnel-down"') {
            $tunnelid = if ($line -match 'tunnelid=(\d+)') { $matches[1].Trim() }
            $date = if ($line -match 'date=(\d{4}-\d{2}-\d{2})') { $matches[1] }
            $time = if ($line -match 'time=(\d{2}:\d{2}:\d{2})') { $matches[1] }
            $endTime = [datetime]::ParseExact("$date $time", "yyyy-MM-dd HH:mm:ss", $null)

            if ($tunnels.ContainsKey($tunnelid)) {
                $tunnels[$tunnelid].EndTime = $endTime
                $tunnels[$tunnelid].Duration = [Math]::Round(($endTime - $tunnels[$tunnelid].StartTime).TotalHours,2)
            }
        }
    }
}

# Ordeno por fecha de inicio
$tunnelSessions = $tunnels.Values | Sort-Object {$_.StartTime}

# Filtrar túneles completos (con inicio y fin)
# $tunnelSessions = $tunnels.Values | Where-Object { $_.EndTime -ne $null }

# Mostrar resultados en formato de tabla
$tunnelSessions | Format-Table -AutoSize

# Exportar resultados a CSV
$tunnelSessions | Export-Csv -Path $outputCsvPath -NoTypeInformation
