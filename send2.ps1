Clear-Content -Path "C:\scripts\log.tmp"
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
    $notSentFiles = Get-Content "C:\scripts\log.err"

    $filesToTransfer = Get-Content -Path "C:\scripts\log.err"

    foreach ($file in $filesToTransfer) {
        $localPath = "C:\log2"
        $remotePath = "/logs/$file"
        $transferResult = $session.PutFiles(($localPath + "\" + $file), $remotePath)

        if ($transferResult.IsSuccess) {
            Write-Host "Success $file"
            Add-Content -Path "C:\scripts\log.tmp" -Value $file
	}
        }
	
    } 
catch {
            Write-Host "ERROR $($file)"
} 
finally {
    $session.Dispose()
}
Add-Content -Path "C:\scripts\log.txt" -Value (Get-Content -Path "C:\scripts\log.tmp")