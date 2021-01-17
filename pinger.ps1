# Для корректной работы скрипта необходим файл с ip адресами устройств.
# Файл с ip адресами устройств должен находится в папке скрипта и иметь имя gw.txt
# При запуске скрипта происходит проверка файла .\gw.txt, если он отсутствует, скрипт предлагает его создать.
# Формат файла gw.txt:
# 10.1.1.1
# 10.1.1.2
#
# Скрипт во время работы создает файлы отчетов:
# Отчет успешной проверки .\pinger.csv
# Отчет не доступных ip .\failPing.log


Set-Location $PSScriptRoot
$loc = Get-Location
$ipv4 = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

while (!(Test-Path ".\gw.txt")) {
Write-Host "Not list IP devices`n" -ForegroundColor Red ;
$chip = Read-Host "Create list IP? y\n "
if ($chip -eq "y") {
         $form = "# Формат файла gw.txt:
         # 10.1.1.1
         # 10.1.1.2
         "
         $form | Out-File ".\gw.txt" -Encoding utf8
         notepad.exe "$($loc.Path)\gw.txt"
        }
 }

function GetData {
Write-Host "
Please enter count check, default 1
" -ForegroundColor Green
$choose = Read-Host "Please enter count"
return $choose
}
do {
$exit = $false
$ex = Read-Host "Сontinue y/n"
if ($ex -eq "n") {$exit = $true}
else {

#while (!($ch)) {}

$NumCheck = GetData
if ($NumCheck.Length -eq 0) {$NumCheck = 1} 
$ipRouters = @()
$ipRouters = Get-Content "$($loc.Path)\gw.txt" | ? {$_ -notlike "*#*" -and $_ -match $ipv4} # path to list ip sanitizer

$Results = @()
$resultOk = @()
$resultFail = @()
$tmpFail = @()
$resultTime = @()
$rows = @()


$job = Test-Connection ($ipRouters) -AsJob -Count 1
$Results = $job | Wait-Job | Receive-Job
$Results | ? {$_.StatusCode -eq 0 } | % {$resultOk += $_.Address}
$Results | ? {$_.StatusCode -eq 0 } | % {$resultTime += $_.Address +' ; '+ $_.ResponseTime + "`n"}
$Results | ? {$_.StatusCode -ne 0 } | % {$resultFail +="$( $_.Address)"}

$tmpRes = @()

#$resultFail.Length

$count = 0
if ($resultFail.Length -ne 0 ) {
do {
sleep 5
#$count
$job = Test-Connection ($resultFail) -AsJob -Count 1
$Results = $job | Wait-Job | Receive-Job
$resultFail = @()
$Results | ? {$_.StatusCode -eq 0 } | % {$resultOk += $_.Address}
$Results | ? {$_.StatusCode -eq 0 } | % {$resultTime += $_.Address +' ; '+ $_.ResponseTime}
$Results | ? {$_.StatusCode -ne 0 } | % {$resultFail +="$( $_.Address)"}

if ((Compare-Object $tmpRes $resultFail).Length -ne 0) {$tmpRes = $resultFail; $count = 0} else {$count++}
} while ($count -lt $NumCheck)
}
$rows = @()
"Ok $($resultOk.Count), fail $( $ipRouters.Count - $resultOk.Count), all $($ipRouters.Count) `n"
"Fail: $resultFail"
(Get-Date).ToString("yy-MM-dd HH:mm") | Out-File ".\failPing.log" -Encoding utf8
$resultFail | Out-File ".\failPing.log"
$resultTime | % {  ; $row = '' | select IP, Time ; $row.IP = $_.Split(';')[0] ; $row.Time = $_.Split(';')[1]; $rows += $row}
$rows | Out-GridView
$rows | export-csv -UseCulture ".\pinger.csv" -Encoding UTF8 }
} while (!($exit))
