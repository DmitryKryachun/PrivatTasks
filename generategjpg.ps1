
$folderPath = ".\screenshots"
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
}

for ($i = 0; $i -le 99; $i++) {
    $random = New-Object Random
    $currentTime = Get-Date
    $currentTime = $currentTime.AddSeconds($i).AddDays($i)
    $fileName = $currentTime.ToString("HHmmss") + ".jpg"
    $filePath = Join-Path -Path $folderPath -ChildPath $fileName

    $randomBytes = New-Object byte[] 1024
    $random.NextBytes($randomBytes)
    [System.IO.File]::WriteAllBytes($filePath, $randomBytes)

    (Get-Item $filePath).CreationTime = $currentTime
}

for ($i = 0; $i -le 99; $i++) {
    $random = New-Object Random
    $currentTime = Get-Date
    $currentTime = $currentTime.AddYears(-1)
    $currentTime = $currentTime.AddSeconds($i).AddDays($i).addHours(1)
    $fileName = $currentTime.ToString("HHmmss") + ".jpg"
    $filePath = Join-Path -Path $folderPath -ChildPath $fileName

    $randomBytes = New-Object byte[] 1024
    $random.NextBytes($randomBytes)
    [System.IO.File]::WriteAllBytes($filePath, $randomBytes)

    (Get-Item $filePath).CreationTime = $currentTime
}

Get-ChildItem -Path $folderPath -Filter *.jpg | ForEach-Object {
    $newFolderPath = Join-Path -Path $folderPath -ChildPath $($_.CreationTime.ToString("yyyy-MM-dd"))
    if (-not (Test-Path $newFolderPath)) {
        New-Item -ItemType Directory -Path $newFolderPath
    }
    Move-Item -Path $_.FullName -Destination $newFolderPath
}