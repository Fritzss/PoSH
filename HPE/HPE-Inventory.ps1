# requed HPEiLOCmdlets https://support.hpe.com/hpsc/swd/public/detail?swItemId=MTX-2596ebfd0d404421be2ea73ca4

Get-Command -Module HPEiLOCmdlets
$user = "<user>"
$pass = Get-Content "<path_to_password>"| ConvertTo-SecureString
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass
$serversIlo = @()
$sermodel = "HPE"
$serversIlo = Find-HPEiLO <iLo NET>
$serversIlo | % {$_.IP}
$report = @()
$inven8 = ''

function gethpeinventory($serversIlo, $credentials){$report =@(); foreach ($ser in $serversIlo) { try {Disconnect-HPEiLO -Connection $conilo8 } catch {} ;
                                                                      try { $conilo8 = Connect-HPEiLO -Credential $credentials -Address $ser.IP -DisableCertificateAuthentication -timeout 200 -ErrorAction stop } catch {  ($_.tostring()).split(":")[0] | Out-File C:\test\pscript\failHPE.txt -Apappend }
                                                                      $server = '';
                                                                      try {$server = Get-HPEiLOServerInfo -Connection $conilo8 ; sleep 1;} catch {}# $c += 1;
                                                                      $hdd = ''
                                                                      $hdd = Get-HPEiLOSmartArrayStorageController -Connection $conilo8 ; sleep 1;# $c += 1 ;
                                                                      if (($hdd.Controllers).Length -gt 0) {
                                                                      $HDDC = ($hdd.Controllers.PhysicalDrives.Count)
                                                                      $HDDSize = ((($hdd.Controllers[0].PhysicalDrives.CapacityGB) | select -Unique) -join ",")
                                                                      $HDDType = ((($hdd.Controllers[0].PhysicalDrives.MediaType) | select -Unique) -join ",")
                                                                      $HDDModel = ((($hdd.Controllers[0].PhysicalDrives.Model) | select -Unique)-join ",")
                                                                      } else {
                                                                      $HDDC = " - "
                                                                      $HDDSize =  " - "
                                                                      $HDDType =  " - "
                                                                      $HDDModel = " - "
                                                                      }
                                                                      if ($ser.PN -like "*ilo 5*") {
                                                                                                    $PCI = Get-HPEiLOPCIDeviceInventory -Connection $conilo8;
                                                                                                    $PCI = (($PCI.PCIDevice.Name) -join ",")
                                                                                                    } else {$PCI = ' -'};
                                                                      $countMemory = 0;
                                                                      $server.MemoryInfo.MemoryDetails.MemoryData.DIMMStatus | % {if ($_ -like "*Good*") {$countMemory += 1 }};
                                                                      $row = '' | select IP, SerialNumber, Model, HostName, CPU, CPU_Model, MemoryPlank, MemorySlot, MemoryPartNum, MemoryTotalSizeGB, MemorySizeGB, MemoryType, HDD, HDDSize, HDDType, HDDModel, NICinfo, PCI
                                                                             $row.IP = $ser.IP
                                                                             $row.SerialNumber = $ser.SerialNumber
                                                                             $row.Model = $ser.SPN
                                                                             $row.HostName = $server.ServerName
                                                                             $row.CPU = $server.ProcessorInfo.Count
                                                                             $row.CPU_Model = ((($server.ProcessorInfo.Model)| select -Unique) -join ",")
                                                                             $row.MemoryPlank = $countMemory
                                                                             $row.MemorySlot = (($server.MemoryInfo.MemoryDetails.MemoryData | ? {$_.DIMMStatus -like "*Good*"} | % {$_.Slot}) -join ",")
                                                                             $row.MemoryPartNum = ((($server.MemoryInfo.MemoryDetails.MemoryData.PartNumber) | ? {$_ -notlike "*N*"}  | select -Unique) -join ",")
                                                                             $row.MemoryTotalSizeGB = (($server.MemoryInfo.MemoryDetailsSummary.TotalMemorySizeGB) -join ",")
                                                                             $row.MemorySizeGB = ((($server.MemoryInfo.MemoryDetails.MemoryData.CapacityMib) | select -Unique | % {$_ / 1024 })  -join ",")
                                                                             $row.MemoryType = ((($server.MemoryInfo.MemoryDetails.memoryData.memorydevicetype)  | ? {$_ -notlike "*N*"} | select -Unique) -join ",")
                                                                             $row.HDD = $HDDC
                                                                             $row.HDDSize = $HDDSize
                                                                             $row.HDDType = $HDDType
                                                                             $row.HDDModel = $HDDModel
                                                                             $row.HDDSN = (($hdd.Controllers[0].PhysicalDrives.SerialNumber) -join ",")
                                                                             $row.NICinfo = (($server.NICInfo.NetworkAdapter.Name) -join ",")
                                                                             $row.PCI = $PCI
                                                                             $report += $row
                                                                            }
                                                             return $report
                                                            }
$inven = gethpeinventory -serversIlo $serversIlo -credentials $credentials 
$inven | Out-GridView
$inven = $inven | Sort-Object | Get-Unique -AsString
$inven | Export-Csv -Delimiter ';' -Encoding UTF8 -Path <path_to_report>$sermodel.csv
