# Lista todos los miembros de los grupos especicificado en un archivo de texto
# Busca los grupos en mas de un subdominio, ademas tiene en cuenta que si hay mas de 2000 objetos en una OU. 

Import-Module ActiveDirectory

# Lista de dominios alternativos (agrega aquí los que necesites)
$dominiosAlternativos = @("subdominio1.dominio.tec", "subdominio2.dominio.tec","subdominio3.dominio.tec")
# Solicitar la ruta del archivo de texto
$archivoGrupos = Read-Host "Ingrese la ruta del archivo de texto con los grupos (uno por línea)"

# Verificar que el archivo existe
if (-not (Test-Path $archivoGrupos)) {
    Write-Host "El archivo '$archivoGrupos' no existe." -ForegroundColor Red
    Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
    Read-Host
    return
}

# Leer los grupos del archivo
try {
    $grupos = Get-Content $archivoGrupos | Where-Object { $_.Trim() -ne "" }
    if ($grupos.Count -eq 0) {
        Write-Host "El archivo no contiene grupos válidos." -ForegroundColor Yellow
        Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
        Read-Host
        return
    }
    
    Write-Host "Se procesarán $($grupos.Count) grupos:" -ForegroundColor Cyan
    $grupos | ForEach-Object { Write-Host "- $_" -ForegroundColor Gray }
    Write-Host ""
    
} catch {
    Write-Host "Error al leer el archivo: $_" -ForegroundColor Red
    Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
    Read-Host
    return
}

# Colección para almacenar todos los resultados
$todosLosResultados = @()

# Procesar cada grupo
foreach ($groupName in $grupos) {
    $groupName = $groupName.TrimEnd()
    
    if ([string]::IsNullOrWhiteSpace($groupName)) {
        continue
    }
    
    Write-Host "Procesando grupo: '$groupName'" -ForegroundColor Yellow
    
    try {
        # Obtener miembros del grupo
        $group = Get-ADGroup -Identity $groupName -Properties Member -ErrorAction Stop
        
        if (-not $group.Member -or $group.Member.Count -eq 0) {
            Write-Host "  El grupo '$groupName' no tiene miembros." -ForegroundColor DarkYellow
            continue
        }
        
        $usuarios = @()
        
        foreach ($dn in $group.Member) {
            $usuario = $null
            
            # Intentar primero en el dominio actual
            try {
                $usuario = Get-ADUser -Identity $dn -Properties SamAccountName, DisplayName, UserPrincipalName -ErrorAction Stop
            } catch {
                # Si falla, intentar en cada dominio alternativo
                foreach ($dom in $dominiosAlternativos) {
                    try {
                        $usuario = Get-ADUser -Identity $dn -Server $dom `
                            -Properties SamAccountName, DisplayName, UserPrincipalName -ErrorAction Stop
                        if ($usuario) { break } # salir si encontró el usuario
                    } catch {
                        # seguir al siguiente dominio
                    }
                }
                if (-not $usuario) {
                    Write-Host "    No se pudo obtener el usuario en ningún dominio: $dn" -ForegroundColor DarkYellow
                }
            }
            
            # Agregar usuario si se resolvió
            if ($usuario) {
                # Agregar el nombre del grupo como propiedad adicional
                $usuarioConGrupo = $usuario | Select-Object Name, SamAccountName, UserPrincipalName, @{Name="Grupo";Expression={$groupName}}
                $usuarios += $usuarioConGrupo
            }
        }
        
        # Agregar usuarios de este grupo a la colección total
        $todosLosResultados += $usuarios
        
        Write-Host "  Usuarios encontrados en '$groupName': $($usuarios.Count)" -ForegroundColor Green
        
    } catch {
        Write-Host "  Error al procesar el grupo '$groupName': $_" -ForegroundColor Red
    }
}

# Mostrar resultados consolidados
if ($todosLosResultados.Count -gt 0) {
    Write-Host "`n=== RESULTADOS CONSOLIDADOS ===" -ForegroundColor Cyan
    Write-Host "Total de usuarios encontrados: $($todosLosResultados.Count)" -ForegroundColor Green
    
    $resultadosOrdenados = $todosLosResultados | Sort-Object Grupo, Name
    $resultadosOrdenados | Format-Table -AutoSize
    
    # Exportar si se desea
    $export = Read-Host "¿Desea exportar los resultados a un archivo CSV? (s/n)"
    if ($export -match '^[sS]$') {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $defaultPath = "AD_Groups_Export_$timestamp.csv"
        $path = Read-Host "Ingrese la ruta completa para guardar el archivo CSV (Enter para usar '$defaultPath')"
        
        if ([string]::IsNullOrWhiteSpace($path)) {
            $path = $defaultPath
        }
        
        try {
            $resultadosOrdenados | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
            Write-Host "Archivo CSV exportado exitosamente a $path" -ForegroundColor Green
        } catch {
            Write-Host "Error al exportar el archivo: $_" -ForegroundColor Red
        }
    }
    
    # Mostrar resumen por grupo
    Write-Host "`n=== RESUMEN POR GRUPO ===" -ForegroundColor Cyan
    $resumenGrupos = $todosLosResultados | Group-Object Grupo | Select-Object Name, Count | Sort-Object Name
    $resumenGrupos | Format-Table -AutoSize
    
} else {
    Write-Host "`nNo se encontraron usuarios en ninguno de los grupos procesados." -ForegroundColor Yellow
}

Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
Read-Host
