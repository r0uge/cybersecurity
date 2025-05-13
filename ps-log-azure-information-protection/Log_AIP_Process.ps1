# Ruta del archivo de entrada y salida
$archivoEntrada = "AIP_Log.txt"
$archivoSalida = "AIP_Log_Process.csv"

# Diccionario de etiquetas de sensibilidad
$etiquetas = @{
"a478f1c7-4ced-489f-9c25-1189acd1579d" = "Public"
"89466092-a22a-4827-9d72-d00494a09567" = "Internal Use"
"aa401f51-9910-48e5-911d-965229c964b7" = "Confidential"
"c8865157-e14f-48c3-bede-d8da518acad7" = "Highly Confidential"
"9776d702-72c3-449a-9ac5-45a1959c3d87" = "Highly Confidential SF"
"0907b86e-3fc4-4900-81e7-429cf74cddab" = "SF 0001"
"3bd61f44-ddda-4f04-a550-455a508616df" = "SF_0000065"
"d2e45969-1dbd-4256-9420-306f51e3163e" = "SF_0000104"
"422e77ff-bc33-4ffd-88a1-6ce9dd37a5db" = "SF_0000093"
"7199bd95-524e-48ea-8197-ae5cc710ba8b" = "SF_0000093 - Unprotected"
"7c346852-9dba-4645-9515-6fa39af3329c" = "SF_0000047"
"66544504-78e7-4f86-94fc-4aed26e50a82" = "SF_0000047 - Unprotected"
"b73b8676-a737-4ca9-86d1-44b783b719c3" = "Unprotect"
"4d83633c-35fa-4f86-b0d3-78cf1aebf29a" = "SF_0000105"
"8a0eb524-250b-41a8-a586-e2bc70af63ed" = "SF_0000002"
"4b186c4e-e9c5-4c2b-9e2f-5b52af553912" = "SF_0000003"
"9db483aa-9376-4d6c-ad08-187fb7a43163" = "SF_0000004"
"1a3ed1bb-71c2-4ea4-9202-1c98218ad565" = "SF_0000005"
"a88dfd27-dc02-4daa-a371-8108dff60e0d" = "SF_0000006"
"54daae3d-04cc-4bbc-8066-b78763169d57" = "SF_0000008"
"ea8d16fb-716c-4d7e-9a96-0b2e8b1b0123" = "SF_0000012"
"a3b0b042-3479-4610-9406-62c622bc5b9d" = "SF_0000036"
"b082cae2-1e2a-4075-bdb5-8b4e31c6af83" = "SF_0000048"
"1af13eb9-d7fa-4814-881a-5a08fe3996c3" = "SF_0000060"
"05ae2b0f-4153-472c-9a89-2441c55e11ae" = "SF_0000062"
"3c6fe9f5-aa85-42ad-82e0-2839aa7309fe" = "SF_0000102"
"176c2850-9f5f-4f50-8971-2bc6b96eb856" = "SF_0000092"
"079cc889-77ea-4eda-bdf2-1c4e755cab99" = "SF_0000033"
"07eac7e2-a958-4246-8cc8-6565252e784c" = "SF_0000035"
"d46e2c4f-5c7f-413d-898c-ef58b527c39d" = "SF_0000061"
"a0db98fe-8f1c-4f63-8437-e41cb08f59ab" = "SF_0000096"
"53333d7f-e07a-46e3-8748-ac42ae532648" = "SF_0000098"
"f7a4b184-f2ad-46aa-9ab5-9ea08c77d57d" = "SF_0000101"
"3f833992-d22a-4e56-bfab-8b90e9eb20d1" = "SF_0000007"
"b1580c82-98fb-4f73-a90c-2ad9c905398e" = "SF_0000009"
"8c08e347-635c-41f4-a76e-367634e4b263" = "SF_0000010"
"ae1460a6-0526-478c-84e0-744e4476c4f8" = "SF_0000011"
"a0c18879-8773-465d-a4d0-9c51ba691c0d" = "SF_0000031"
"5155f5c1-849f-4220-9ecf-a4509b4a6cae" = "SF_0000032"
"5f6281be-25f1-4a83-8514-3ff4eb7d70a0" = "SF_0000037"
"3cde5cfc-111e-459e-a22c-97befe066f00" = "SF_0000038"
"71e14885-d932-4a85-89c6-fe757c8bafcb" = "SF_0000039"
"a05f9b6e-84b4-41d0-b052-d4e2dd208960" = "SF_0000040"
"b0407ccb-7e7b-4efb-952c-ed0274195594" = "SF_0000046"
"37a4d986-f4c2-4af5-af80-844fa67f17d4" = "SF_0000057"
"692c6f52-ff71-46bd-a47c-67c5b0e43604" = "SF_0000058"
"10a5e931-0b3f-4ba8-9cc3-c8952f770645" = "SF_0000059"
"bd563cf2-9110-449b-b938-3237f6b2d83b" = "SF_0000066"
"9c867db3-fa0d-48bd-910e-f8a35189984b" = "SF_0000067"
"1640e64b-b66b-49f9-84c9-4ccb1b2b8598" = "SF_0000068"
"d4e41101-18ae-4271-881d-d873260ba9bd" = "SF_0000070"
"ea60b688-1dc9-46f4-89cf-9558e0fde603" = "SF_0000071"
"3daeb5ed-75f5-4732-b1ac-4d57c1b8a4c2" = "SF_0000072"
"ca22f23f-32e9-4b0d-981e-d3495d40210e" = "SF_0000073"
"c33bf0da-a7e9-4eec-a12a-184b44eacd5b" = "SF_0000074"
"4a85b9ff-d27c-4d46-be93-fd398d7cb33d" = "SF_0000075"
"0601258c-d4c1-43f1-8b5b-478492fb1fe3" = "SF_0000076"
"af60b381-6301-4d31-9b59-4fd2c129b02d" = "SF_0000077"
"39fd8f1a-00da-4122-babc-099fc920df51" = "SF_0000078"
"c0c76a47-8735-4c6a-b9f3-d09890f61ce6" = "SF_0000079"
"9ee6b71a-8230-4468-a158-cbdf7685f0fb" = "SF_0000080"
"ee7899e4-3acb-4a3a-bc0e-9de3839d9e3d" = "SF_0000082"
"1ebd982d-9ce6-422e-9b68-daf44557dce7" = "SF_0000083"
"f2b918b8-9452-48af-b344-f58c2de39b94" = "SF_0000085"
"e792626b-8639-44c7-8ecd-247c10f798f7" = "SF_0000086"
"467b456c-27db-409f-84b3-93521acaafa4" = "SF_0000087"
"03a97b14-da07-474c-b30d-b2e5e8515d97" = "SF_0000088"
"339e4bb7-f9d2-413a-8623-1a9fbc0c70e2" = "SF_0000089"
"cd488fd3-6bbd-43b7-bcfb-efc52040a1af" = "SF_0000090"
"cb54b19b-12d1-458c-a58a-9544b24d34a3" = "SF_0000091"
"24eb5700-f9e9-4f87-be08-b8ee0597e74b" = "SF_0000099"
"32f45933-081e-4540-8cd0-70bf1937e06a" = "SF_0000100"
"359a479c-a03e-4c63-b71a-7a9dcf062039" = "SF_0000103"
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
