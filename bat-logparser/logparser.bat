@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: Configuración de variables
set "ARCHIVO_ORIGEN=C:\A\f.csv"
set "ARCHIVO_BACKUP=C:\A\f_backup.csv"
set "LOGPARSER_PATH=C:\Log Parser 2.2\LogParser"
set "DIRECTORIO_ORIGEN=D:\A\*.csv"
:: Crear timestamp limpio para el nombre del archivo
set "fecha=%date:~-4,4%%date:~-10,2%%date:~-7,2%"
set "hora=%time:~0,2%%time:~3,2%%time:~6,2%"
:: Limpiar espacios en la hora (puede haber espacios si es antes de las 10 AM)
set "hora=%hora: =0%"
set "ARCHIVO_LOG=C:\A\logparser_execution_%fecha%_%hora%.log"

echo =========================================
echo SCRIPT DE BACKUP Y LOGPARSER
echo =========================================
echo Inicio: %date% %time%
echo.

:: 1. GENERAR BACKUP
echo [1/4] Generando backup de %ARCHIVO_ORIGEN%...
if exist "%ARCHIVO_ORIGEN%" (
    if exist "%ARCHIVO_BACKUP%" (
        echo   - Eliminando backup anterior...
        del "%ARCHIVO_BACKUP%"
    )
    echo   - Creando backup...
    copy "%ARCHIVO_ORIGEN%" "%ARCHIVO_BACKUP%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   - Backup creado exitosamente: %ARCHIVO_BACKUP%
    ) else (
        echo   - ERROR: No se pudo crear el backup
        goto :error
    )
) else (
    echo   - ADVERTENCIA: Archivo origen no existe, continuando sin backup...
)

echo.

:: 2. MOSTRAR TAMAÑO DEL BACKUP
if exist "%ARCHIVO_BACKUP%" (
    for %%F in ("%ARCHIVO_BACKUP%") do (
        set "tamano_backup_bytes=%%~zF"
        call :ConvertirAMBSimple !tamano_backup_bytes! tamano_backup_mb
        echo   - Tamaño del backup: !tamano_backup_mb! MB ^(!tamano_backup_bytes! bytes^)
    )
) else (
    set "tamano_backup_bytes=0"
    set "tamano_backup_mb=0.00"
    echo   - No hay backup previo (archivo nuevo)
)

echo.

:: 3. EJECUTAR LOGPARSER
echo [2/4] Ejecutando LogParser...
echo   - Comando: "%LOGPARSER_PATH%" "SELECT * INTO %ARCHIVO_ORIGEN% FROM %DIRECTORIO_ORIGEN% WHERE SensitivityLabel IS NOT NULL AND SensitivityLabel <> ''" -i:CSV -o:CSV
echo   - Procesando archivos de %DIRECTORIO_ORIGEN%...
echo.

:: Ejecutar LogParser y capturar la salida
"%LOGPARSER_PATH%" "SELECT * INTO %ARCHIVO_ORIGEN% FROM %DIRECTORIO_ORIGEN% WHERE SensitivityLabel IS NOT NULL AND SensitivityLabel <> ''" -i:CSV -o:CSV > temp_logparser_output.txt 2>&1

set "logparser_exit_code=%errorlevel%"

:: Mostrar output de LogParser
type temp_logparser_output.txt

echo.

:: 4. VERIFICAR RESULTADO Y MOSTRAR ESTADÍSTICAS
echo [3/4] Verificando resultado...
if %logparser_exit_code% equ 0 (
    echo   - LogParser ejecutado exitosamente
    
    :: Mostrar tamaño final del archivo
    if exist "%ARCHIVO_ORIGEN%" (
        for %%F in ("%ARCHIVO_ORIGEN%") do (
            set "tamano_final_bytes=%%~zF"
            call :ConvertirAMBSimple !tamano_final_bytes! tamano_final_mb
            echo   - Tamaño final del archivo: !tamano_final_mb! MB ^(!tamano_final_bytes! bytes^)
            call :CalcularDiferenciaBasica !tamano_final_bytes! !tamano_backup_bytes!
            echo   - Diferencia respecto al backup: !diferencia_resultado!
        )
    ) else (
        echo   - ERROR: El archivo de salida no fue creado
        set "tamano_final_bytes=0"
        set "tamano_final_mb=0.00"
        goto :error
    )
) else (
    echo   - ERROR: LogParser falló con código de salida: %logparser_exit_code%
    goto :error
)

echo.

:: 5. GENERAR LOG DE ÉXITO
echo [4/4] Generando log de ejecución...
(
    echo =========================================
    echo LOG DE EJECUCIÓN - LOGPARSER BACKUP SCRIPT
    echo =========================================
    echo Fecha y hora de inicio: %date% %time%
    echo.
    echo CONFIGURACIÓN:
    echo - Archivo origen: %ARCHIVO_ORIGEN%
    echo - Archivo backup: %ARCHIVO_BACKUP%
    echo - Directorio fuente: %DIRECTORIO_ORIGEN%
    echo.
    echo ESTADÍSTICAS:
    echo - Tamaño del backup: !tamano_backup_mb! MB ^(!tamano_backup_bytes! bytes^)
    echo - Tamaño final: !tamano_final_mb! MB ^(!tamano_final_bytes! bytes^)
    echo - Diferencia respecto al backup: !diferencia_resultado!
    echo - Código de salida LogParser: %logparser_exit_code%
    echo.
    echo SALIDA DE LOGPARSER:
    type temp_logparser_output.txt
    echo.
    echo =========================================
    echo EJECUCIÓN COMPLETADA EXITOSAMENTE
    echo Fecha y hora de finalización: %date% %time%
    echo =========================================
) > "%ARCHIVO_LOG%"

echo   - Log generado: %ARCHIVO_LOG%
echo.
echo =========================================
echo PROCESO COMPLETADO EXITOSAMENTE
echo =========================================
goto :end

:error
echo.
echo =========================================
echo ERROR EN LA EJECUCIÓN
echo =========================================
(
    echo =========================================
    echo LOG DE EJECUCIÓN - ERROR
    echo =========================================
    echo Fecha y hora: %date% %time%
    echo.
    echo ERROR: El script no se ejecutó correctamente
    echo Código de salida LogParser: %logparser_exit_code%
    echo.
    echo SALIDA DE LOGPARSER:
    if exist temp_logparser_output.txt type temp_logparser_output.txt
    echo.
    echo =========================================
) > "%ARCHIVO_LOG%"
echo Log de error generado: %ARCHIVO_LOG%
exit /b 1

:end
:: Limpiar archivos temporales
if exist temp_logparser_output.txt del temp_logparser_output.txt

echo.
echo Recordar Actualizar Dashboard de PowerBI
echo.


echo.
echo Presiona cualquier tecla para salir...
pause >nul
exit /b 0

:: ==========================================
:: FUNCIONES AUXILIARES - SOLO BATCH
:: ==========================================

:ConvertirAMBSimple
:: Versión ultra-simplificada que evita problemas de sintaxis
:: Parámetros: %1=bytes, %2=variable_salida
setlocal enabledelayedexpansion
set "bytes=%~1"

:: Si es 0, retornar 0.00
if "%bytes%"=="0" (
    endlocal & set "%~2=0.00"
    goto :eof
)

:: Intentar conversión directa
set /a "mb_entero=bytes / 1048576" 2>nul
if errorlevel 1 (
    :: Para archivos muy grandes, aproximación básica
    set "len_str=%bytes%"
    set "len_str=!len_str:~8!"
    if "!len_str!"=="" (
        :: Número de menos de 9 dígitos, intentar de nuevo
        set /a "mb_entero=bytes / 1000000"
        set "resultado=!mb_entero!.00"
    ) else (
        :: Número muy grande, usar aproximación
        set "primeros=%bytes:~0,6%"
        set /a "mb_aprox=primeros / 1000"
        set "resultado=!mb_aprox!.00"
    )
) else (
    :: Conversión exitosa, calcular decimales
    set /a "resto=bytes %% 1048576"
    set /a "decimal=(resto * 100) / 1048576"
    if !decimal! lss 10 set "decimal=0!decimal!"
    set "resultado=!mb_entero!.!decimal!"
)

endlocal & set "%~2=%resultado%"
goto :eof

:CalcularDiferenciaBasica
:: Versión ultra-básica para evitar errores
:: Parámetros: %1=final_bytes, %2=backup_bytes
setlocal enabledelayedexpansion
set "final=%~1"
set "backup=%~2"

:: Intentar resta simple
set /a "diferencia=final-backup" 2>nul
if errorlevel 1 (
    :: Si hay overflow, mostrar mensaje genérico
    if %final% gtr %backup% (
        set "resultado=+[archivo mayor]"
    ) else (
        set "resultado=-[archivo menor]"
    )
) else (
    :: Conversión exitosa
    if %diferencia% gtr 0 (
        call :ConvertirAMBSimple %diferencia% diff_mb
        set "resultado=+!diff_mb! MB"
    ) else if %diferencia% lss 0 (
        set /a "diferencia_abs=0-diferencia"
        call :ConvertirAMBSimple !diferencia_abs! diff_mb
        set "resultado=-!diff_mb! MB"
    ) else (
        set "resultado=0.00 MB (sin cambios)"
    )
)

endlocal & set "diferencia_resultado=%resultado%"
goto :eof

if %diff_len% gtr 0 set /a "diff_aprox*=10"

endlocal & set "%~3=%diff_aprox%"
goto :eof
