# Параметры для подключения к Google Sheets API и БД PostgreSQL
$JsonKeyFilePath = "C:\Scripts\tosheets-416011-b236c3405cf9.json"
$SpreadsheetId = "1ZnK0RZxwEH1_-3M6SJGybX_Hd-jLfSe9I_e-HckL3G0"
$SheetName = "Sheet1"
$ConnectionString = "DRIVER={PostgreSQL ANSI};SERVER=localhost;PORT=5432;DATABASE=postgres;UID=postgres;PWD=postgres;"

# Функция для выполнения запросов к БД PostgreSQL через ODBC
$connection = New-Object System.Data.Odbc.OdbcConnection;
$connection.ConnectionString = $ConnectionString;
$connection.Open();
$DBCmd = $connection.CreateCommand();
    $DBCmd.CommandText = "SELECT filename FROM archivefiles"
    $result=$DBCmd.ExecuteReader();

# Функция для отправки данных в Google Sheets через HTTP запросы
function Write-ToGoogleSheets {
    param (
        [string]$JsonKeyFilePath,
        [string]$SpreadsheetId,
        [string]$SheetName,
        [array]$Data
    )

    # Чтение ключа доступа из JSON файла
    $ServiceAccountKey = Get-Content $JsonKeyFilePath | ConvertFrom-Json

    # Создание JWT (JSON Web Token)
    $Base64PrivateKey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ServiceAccountKey.private_key))
    $JwtHeader = @{alg="RS256"; typ="JWT"}
    $JwtPayload = @{
        iss = $ServiceAccountKey.client_email
        scope = "https://www.googleapis.com/auth/spreadsheets"
        aud = "https://oauth2.googleapis.com/token"
        exp = [math]::Round((Get-Date -UFormat %s) + 3600)
        iat = (Get-Date -UFormat %s)
    }
    $JwtHeaderBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($JwtHeader | ConvertTo-Json)))
    $JwtPayloadBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($JwtPayload | ConvertTo-Json)))
    $JwtSignatureBase64 = [Convert]::ToBase64String((New-Object Security.Cryptography.RSACryptoServiceProvider).SignData([System.Text.Encoding]::UTF8.GetBytes("$JwtHeaderBase64.$JwtPayloadBase64"), 'SHA256'))

    $JwtToken = "$JwtHeaderBase64.$JwtPayloadBase64.$JwtSignatureBase64"

    # Получение OAuth2 токена
    $TokenRequest = @{
        method = "POST"
        Uri = "https://oauth2.googleapis.com/token"
        Headers = @{
            "Content-Type" = "application/json"
        }
        Body = @{
            grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer"
            assertion = $JwtToken
        } | ConvertTo-Json
    }
    $TokenResponse = Invoke-RestMethod @TokenRequest

    # Формирование заголовков для запроса к Google Sheets API
    $Headers = @{
        "Authorization" = "Bearer $($TokenResponse.access_token)"
    }

    # Формирование тела запроса для обновления данных в Google Sheets
    $RequestBody = @{
        "range" = "$SheetName!A1"
        "majorDimension" = "ROWS"
        "values" = @($Data)
    } | ConvertTo-Json

    # Отправка запроса к Google Sheets API для обновления данных
    try {
        Invoke-RestMethod -Uri "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId/values/$SheetName!A1:append?valueInputOption=USER_ENTERED" -Method Post -Headers $Headers -Body $RequestBody -ErrorAction Stop | Out-Null
    } catch {
        Write-Host "Failed to update Google Sheets: $_"
    }
}

# Получаем имена архивов из БД PostgreSQL


# Преобразуем результат запроса в массив данных для записи в Google Sheets
$Data = @()
foreach ($row in $result.Rows) {
    $Data += @($row[0])
}

# Записываем данные в Google Sheets
Write-ToGoogleSheets -JsonKeyFilePath $JsonKeyFilePath -SpreadsheetId $SpreadsheetId -SheetName $SheetName -Data $Data
