
$logDirectory = "C:\log"


$log2Directory = "C:\log2"

$remainingLogs = Get-ChildItem -Path $logDirectory -Filter "*.log"
foreach ($logFile in $remainingLogs) {
    $zipName = Join-Path -Path $log2Directory -ChildPath ($logFile.BaseName + ".zip")
    if (-not (Test-Path -Path $zipName)) {
        Compress-Archive -Path $logFile.FullName -DestinationPath $zipName
    }
}