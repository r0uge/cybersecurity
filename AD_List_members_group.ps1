#Lista todos los miembros de un grupo de AD dado, buscando en diferentes subdominios

Import-Module ActiveDirectory

# Lista de dominios alternativos (agrega aquí los que necesites)
$dominiosAlternativos = @("subdominio1.dominio.net", "subdominio2.dominio.net", "subdominio3.dominio.net")

# Ingreso de grupo
$groupName = (Read-Host "Ingrese el nombre del grupo de AD").TrimEnd()

try {
    # Obtener miembros del grupo
    $group = Get-ADGroup -Identity $groupName -Properties Member -ErrorAction Stop

    if (-not $group.Member -or $group.Member.Count -eq 0) {
        Write-Host "El grupo '$groupName' no tiene miembros." -ForegroundColor Yellow
        return
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
                Write-Host "No se pudo obtener el usuario en ningún dominio: $dn" -ForegroundColor DarkYellow
            }
        }

        # Agregar usuario si se resolvió
        if ($usuario) {
            $usuarios += $usuario
        }
    }

    # Mostrar resultados
    $resultados = $usuarios | Select-Object Name, SamAccountName, UserPrincipalName | Sort-Object Name
    $resultados | Format-Table -AutoSize

    # Exportar si se desea
    $export = Read-Host "¿Desea exportar los resultados a un archivo CSV? (s/n)"
    if ($export -match '^[sS]$') {
        $path = Read-Host "Ingrese la ruta completa para guardar el archivo CSV"
        $resultados | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
        Write-Host "Archivo CSV exportado exitosamente a $path" -ForegroundColor Green
    }

} catch {
    Write-Host "Error general: $_" -ForegroundColor Red
}

Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
Read-Host
