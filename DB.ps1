

$connectionString = "Driver={PostgreSQL Unicode};Server=localhost;Port=5432;Database=postgres;Uid=postgres;Pwd=postgres;"


$connection = New-Object System.Data.Odbc.OdbcConnection;
$connection.ConnectionString = $ConnectionString;
$connection.Open();


if ($connection.State -eq 'Open') {
    Write-Host "success."
    $queryCreateTable = @"
CREATE TABLE IF NOT EXISTS archivefiles (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255)
);
"@

$logFilePath = "C:\scripts\log.txt"
$logData = Get-Content -Path $logFilePath

foreach ($line in $logData) {
    $DBCmd = $connection.CreateCommand();
    $DBCmd.CommandText = "INSERT INTO archivefiles (filename) VALUES ('$line');"
    $result=$DBCmd.ExecuteReader();
}
} else {
    Write-Host "eror connection"
    exit
}

$connection.Close()
