
$directory = "C:\Scripts"


if (-not (Test-Path -Path $directory)) {
    New-Item -Path $directory -ItemType Directory
}


$logErrPath = Join-Path -Path $directory -ChildPath "log.err"
$logTmpPath = Join-Path -Path $directory -ChildPath "log.tmp"
$logTxtPath = Join-Path -Path $directory -ChildPath "log.txt"

Add-Content -Path $logErrPath -Value ""
Add-Content -Path $logTmpPath -Value ""
Add-Content -Path $logTxtPath -Value ""