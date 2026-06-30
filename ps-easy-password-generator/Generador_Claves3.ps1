Add-Type -AssemblyName System.Windows.Forms

# Autor: Agustin Alvarez
# Version: 3.0 (22/05/2024)
# Descripción: Generador de claves iniciales de maximo de 14 caracteres con letras, numeros, 1 mayuscula y 1 caracter especial de facil lectura

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
    $longitudMaxima = 14
    $mayusculaSeleccionada = $false
    $posicionMayuscula = Get-Random -Minimum 0 -Maximum 4

    while ($clave.Length -lt $longitudMaxima) {
        do {
            $palabra = $palabras | Get-Random
        } while ($palabrasUsadas -contains $palabra)

        if ($clave.Length + $palabra.Length + 1 -le $longitudMaxima) {
            $palabrasUsadas += $palabra
            if ($palabrasUsadas.Length -eq $posicionMayuscula -and -not $mayusculaSeleccionada) {
                $palabra = $palabra.Substring(0,1).ToUpper() + $palabra.Substring(1)
                $mayusculaSeleccionada = $true
            }
            $clave += $palabra + "."
        } else {
            break
        }
    }

    # Remover el último punto y agregar un número aleatorio
    $clave = $clave.TrimEnd('.')
    $numero = Get-Random -Minimum 100 -Maximum 999
    if ($clave.Length + $numero.ToString().Length -le $longitudMaxima) {
        $clave += $numero
    }
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
