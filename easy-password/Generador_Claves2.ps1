Add-Type -AssemblyName System.Windows.Forms

# Autor: Agustin Alvarez
# Version: 3.0 (22/05/2024)
# Descripción: Generador de claves iniciales de tres palabras, 3 numeros, 1 mayuscula y caracter especial de facil lectura

# Función para generar la clave
function Generar-ClaveFacil {
    $palabras = @(
        "perro", "gato", "casa", "coche", "playa", "sol", "libro", "jardin", "flor", "arbol",
    "agua", "azul", "verde", "rojo", "blanco", "negro", "luz", "luna", "estrella", "montaña",
    "roca", "cielo", "nieve", "arena", "piedra", "hierba", "hoja", "camino", "mar", "rio",
    "silla", "mesa", "taza", "plato", "ventana", "puerta", "pared", "techo", "piso", "escalera",
    "lunes", "martes", "jueves", "viernes", "sabado", "domingo"
    )

    $clave = ""
    $palabrasUsadas = @()
    $longitud = Get-Random -Minimum 3 -Maximum 4
    $mayusculaSeleccionada = $false
    $posicionMayuscula = Get-Random -Minimum 0 -Maximum $longitud
    for ($i = 0; $i -lt $longitud; $i++) {
        do {
            $palabra = $palabras | Get-Random
        } while ($palabrasUsadas -contains $palabra)
        $palabrasUsadas += $palabra
        if ($i -eq $posicionMayuscula -and -not $mayusculaSeleccionada) {
            $palabra = $palabra.Substring(0,1).ToUpper() + $palabra.Substring(1)
            $mayusculaSeleccionada = $true
        }
        $clave += $palabra + "."
    }

    $clave += Get-Random -Minimum 100 -Maximum 999
    return $clave
}

# Crear formulario
$form = New-Object System.Windows.Forms.Form
$form.Text = "Generador de Claves Fácil"
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = "CenterScreen"

# Etiqueta para mostrar la clave generada
$labelEtiqueta = New-Object System.Windows.Forms.Label
$labelEtiqueta.Location = New-Object System.Drawing.Point(10,10)
$labelEtiqueta.Size = New-Object System.Drawing.Size(280,40)
$labelEtiqueta.Text = "Clave Generada"
$labelEtiqueta.TextAlign = "MiddleCenter"
#$labelClave.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)

$labelClave = New-Object System.Windows.Forms.Label
$labelClave.Location = New-Object System.Drawing.Point(10,50)
$labelClave.Size = New-Object System.Drawing.Size(280,40)
$labelClave.Text = "$clave"
$labelClave.TextAlign = "MiddleCenter"
$labelClave.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)

# Botón para generar nueva clave
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(70,120)
$button.Size = New-Object System.Drawing.Size(150,30)
$button.Text = "Generar Nueva Clave"

# Manejador de evento para el botón
$button.Add_Click({
    $clave = Generar-ClaveFacil
    $labelClave.Text = "$clave"
    # Copiar al portapapeles
    [System.Windows.Forms.Clipboard]::SetText($clave)
})

# Agregar controles al formulario
$form.Controls.Add($labelEtiqueta)
$form.Controls.Add($labelClave)
$form.Controls.Add($button)

# Mostrar el formulario
$form.ShowDialog() | Out-Null