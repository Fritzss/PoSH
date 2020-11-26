$login = "<login>"
$sec2 = "<password>"
$vpnName="<vpnname>"
while ($true) { 
if (!(Test-Connection <your local address VPN NET> -Count 1 -Quiet)) {rasdial $vpnName /DISCONNECT; rasdial $vpnName $login $sec2 ; sleep 60}
sleep 60
}
