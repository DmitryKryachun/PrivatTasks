
$logDirectory = "C:\log"


$log2Directory = "C:\log2"

$first50Logs = Get-ChildItem -Path $logDirectory -Filter "*.log" | Select-Object -First 50
foreach ($logFile in $first50Logs) {
    $zipName = Join-Path -Path $log2Directory -ChildPath ($logFile.BaseName + ".zip")
    if (-not (Test-Path -Path $zipName)) {
        Compress-Archive -Path $logFile.FullName -DestinationPath $zipName
    }
}
