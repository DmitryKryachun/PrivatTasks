# Путь к JSON-ключу Google Sheets
$jsonKeyPath = "C:\Scripts\tosheets-416011-b236c3405cf9.json"

# Содержимое JSON-ключа
$jsonKey = Get-Content $jsonKeyPath | ConvertFrom-Json

# Параметры для запроса на получение ACCESS_TOKEN
$tokenUrl = "https://oauth2.googleapis.com/token"
$jwtHeader = @{
    "alg" = "RS256"
    "typ" = "JWT"
}
$jwtClaimSet = @{
    "iss" = $jsonKey.client_email
    "scope" = "https://www.googleapis.com/auth/spreadsheets"
    "aud" = $tokenUrl
    "exp" = ([DateTimeOffset]::Now.ToUnixTimeSeconds() + 3600) # Токен будет действителен 1 час
    "iat" = ([DateTimeOffset]::Now.ToUnixTimeSeconds())
}
$jwtHeaderBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($jwtHeader | ConvertTo-Json))
$jwtClaimSetBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($jwtClaimSet | ConvertTo-Json))
$jwtPayload = "$($jwtHeaderBase64).$($jwtClaimSetBase64)"

# Подписываем JWT с использованием приватного ключа из JSON-ключа
$jwtSignature = New-Object Security.Cryptography.RSACryptoServiceProvider
$jwtSignature.ImportParameters(
    (New-Object Security.Cryptography.RSAParameters -Property @{
        Modulus = [Convert]::FromBase64String($jsonKey.private_key)
        Exponent = [Convert]::FromBase64String($jsonKey.private_key_id)
    })
)
$jwtSignatureBytes = $jwtSignature.SignData([System.Text.Encoding]::UTF8.GetBytes($jwtPayload), "SHA256")
$jwtSignatureBase64 = [Convert]::ToBase64String($jwtSignatureBytes)

# Формируем JWT
$jwt = "$jwtPayload.$jwtSignatureBase64"

# Формируем запрос на получение ACCESS_TOKEN
$body = @{
    "grant_type" = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    "assertion" = $jwt
} | ConvertTo-Json

# Отправляем запрос на получение ACCESS_TOKEN
$response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/json"

# Выводим полученный ACCESS_TOKEN
Write-Output $response.access_token
