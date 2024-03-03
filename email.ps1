
$smtpServer = "smtp.office365.com"
$smtpPort = 587
$senderEmail = "email"
$senderPassword = "password"
$recipientEmail = "dmitrokryachun@gmail.com"
$subject = "Log file to email"
$body = "Log file here!"
$attachmentPath = "C:\scripts\log.txt"

Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl `
                 -From $senderEmail -To $recipientEmail `
                 -Subject $subject -Body $body -Attachments $attachmentPath `
                 -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $senderEmail, (ConvertTo-SecureString -String $senderPassword -AsPlainText -Force))
