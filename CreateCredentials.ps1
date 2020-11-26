$pass = Read-Host <path_to_fail>
$cred = Get-Credential
$cred.Password | ConvertFrom-SecureString | Set-Content $pass
