$VPN = <VPNName>
$user = <username>
$pass = <password>
$vpnsrv = <server>
$l2tpPSK = <IPsecKey>

$curPolicy=Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
if (((Get-Command -Module VPNCredentialsHelper).Name).Length -eq 0) {
  Write-Host "Install module VPNCredentialsHelper"
  Install-Module -Name VPNCredentialsHelper -Force
}
Add-VpnConnection -Name FIN -ServerAddress $vpnsrv -TunnelType L2tp -AllUserConnection -L2tpPsk $l2tpPSK  -AuthenticationMethod MSChapv2 -RememberCredential -Force -EncryptionLevel Required

Set-VpnConnectionUsernamePassword -connectionname $VPN -username $user -password $pass -Whatif
Set-ExecutionPolicy -ExecutionPolicy $curPolicy
