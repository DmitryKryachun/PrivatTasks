#1

$folderPath = ".\screenshots"
$disk = (Get-Item $folderPath).FullName.Substring(0,2)
$freeSpace = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DeviceID -eq $disk} | Select-Object -ExpandProperty FreeSpace
$freeSpaceGB = [math]::Round($freeSpace / 1GB, 2)

Write-Host "Remain on ${disk} ${freeSpaceGB} GB"


# 2
$screenshoterRunning = Test-Path ".\screenshots\screenshoter.exe"

if ($screenshoterRunning) {
    Write-Host "App screenshoter.exe running in ./screenshots."
} else {
    Write-Host "App screenshoter.exe stoped or not exist./screenshots."
}

# 3
$today = Get-Date -Format "yyyy-MM-dd"
$currentDayFiles = Get-ChildItem -Path ".\screenshots" -Directory | Where-Object { $_.Name -eq $today }

if ($currentDayFiles) {
    Write-Host "${today} found"
} else {
    Write-Host "${today} NOT found"
}

# 4
$zeroSizeFiles = Get-ChildItem -Path ".\screenshots" -Recurse -File -Filter "*.jpg" | Where-Object { $_.Length -eq 0 }

if ($zeroSizeFiles) {
    Write-Host "Found zero size files"
} else {
    Write-Host "Not found zero files"
}

# 5
$currentDate = Get-Date
$oldFolders = Get-ChildItem -Path ".\screenshots" -Directory | Where-Object { ($currentDate - [datetime]::ParseExact($_.Name, "yyyy-MM-dd", $null)).TotalDays -gt 365 }

foreach ($folder in $oldFolders) {
    Remove-Item -Path $folder.FullName -Recurse -Force
    Write-Host "Deleted $($folder.FullName), since the directory is older than a year"
}

# 6
$mustbeGB = 5
while ($freeSpaceGB -lt $mustbeGB) {
    $sortedFolders = Get-ChildItem -Path ".\screenshots" -Directory | Sort-Object Name
    $needGB = $mustbeGB - $freeSpaceGB
    $totalSizeGB = 0

    foreach ($folder in $sortedFolders) {
        $folderDate = [datetime]::ParseExact($folder.Name, "yyyy-MM-dd", $null)
        $totalSizeGB += (Get-ChildItem -Path $folder.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
        if ($totalSizeGB -gt $needGB) {
            break
        }
        Remove-Item -Path $folder.FullName -Recurse -Force
        Write-Host "Deleted $($folder.FullName), since disk space < 5gb"
    }

    $freeSpace = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DeviceID -eq $disk} | Select-Object -ExpandProperty FreeSpace
    $freeSpaceGB = [math]::Round($freeSpace / 1GB, 2)
}
