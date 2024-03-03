Add-Type -Path "C:\Users\dimon\AppData\Local\Programs\WinSCP\WinSCPnet.dll"

# Указываем параметры подключения к удаленному серверу
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "127.0.1.1"        
    UserName = "oper"
    SshPrivateKeyPath = "C:\scripts\key.ppk"
    SshHostKeyFingerprint = "19tMKWSANyOIrmJxF/+hKJrWvrt6WAnCawzJj/vLHUQ"
    Timeout = New-TimeSpan -Seconds 3
}

$session = New-Object WinSCP.Session

try {
    $session.Open($sessionOptions)

    $localPath = "C:\log2"
    $files = Get-ChildItem -Path $localPath -Filter "*.zip" | Select-Object -First 50

    foreach ($file in $files) {
        $remotePath = "/logs/" + $file.Name
        try {
            $transferResult = $session.PutFiles(($localPath + "\" + $file.Name), $remotePath, $False)

            if ($transferResult.IsSuccess) {
                Write-Host "File $($file.Name) transferred."
                Add-Content -Path "C:\scripts\log.tmp" -Value $file.Name
            }
        } catch {
            Write-Host "ERROR $($file.Name)"
            Add-Content -Path "C:\scripts\log.err" -Value $file.Name
        }
    }
} finally {
    $session.Dispose()
}
