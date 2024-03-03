
Compare-Object -ReferenceObject (Get-Content "C:\scripts\log.err") -DifferenceObject (Get-Content "C:\scripts\log.tmp")

Get-Content "C:\scripts\log.tmp" | Out-File -FilePath "C:\scripts\log.txt"

$notSentFiles = Get-Content "C:\scripts\log.err"

$allFiles = Get-ChildItem -Path "C:\log2\" -Filter "*.zip" | Select-Object -ExpandProperty Name

Compare-Object -ReferenceObject $notSentFiles -DifferenceObject $allFiles
