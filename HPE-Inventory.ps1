# requed HPEiLOCmdlets https://support.hpe.com/hpsc/swd/public/detail?swItemId=MTX-2596ebfd0d404421be2ea73ca4

Get-Command -Module HPEiLOCmdlets
$user = "user"
$pass = Get-Content "<your_path>pass.txt"| ConvertTo-SecureString
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass
$serversIlo = @()
$serversIlo = Find-HPEiLO <your_iLo_NET> #| ? {$_.PN -like "*iLo 5*"} # for iLo 5
$serversIlo | % {$_.IP}
$report = @()

function gethpeinventory($serversIlo, $credentials){$serversIlo | % { $conilo = Connect-HPEiLO -Credential $credentials -Address $_.IP -DisableCertificateAuthentication ;
                                                                      sleep 1;
                                                                      $server = Get-HPEiLOServerInfo -Connection $conilo ;
                                                                      $hdd = Get-HPEiLOSmartArrayStorageController -Connection $conilo ;
								      $pci = Get-HPEiLOPCIDeviceInventory -Connection $conilo
                                                                      Disconnect-HPEiLO -Connection $conilo ;
                                                                      $serial = $_.SerialNumber ; $model = $_.SPN ; $server ; $hdd; $pci
                                                                      $countMemory = 0;
                                                                      $server.MemoryInfo.MemoryDetails.MemoryData.DIMMStatus | % {if ($_ -like "*Good*") {$countMemory = $countMemory +1 }};
                                                                     } | % { $row = '' | select IP, SerialNumber, Model, HostName, CPU, CPU_Model, MemoryPlank, MemorySlot, MemoryPartNum, MemoryTotalSizeGB, MemorySizeGB, MemoryType, HDD, HDDSize, HDDType, HDDModel, HDDSN, NICinfo, PCI
                                                                             $row.IP = $_.IP
                                                                             $row.SerialNumber = $serial
                                                                             $row.Model = $model
                                                                             $row.HostName = $server.ServerName
                                                                             $row.CPU = $server.ProcessorInfo.Count
                                                                             $row.CPU_Model = ((($server.ProcessorInfo.Model)| select -Unique) -join ",")
                                                                             $row.MemoryPlank = $countMemory
                                                                             $row.MemorySlot = (($server.MemoryInfo.MemoryDetails.MemoryData | ? {$_.DIMMStatus -like "*Good*"} | % {$_.Slot}) -join ",")
                                                                             $row.MemoryPartNum = ((($server.MemoryInfo.MemoryDetails.MemoryData.PartNumber) | ? {$_ -notin "*N*"}  | select -Unique) -join ",")
                                                                             $row.MemoryTotalSizeGB = (($server.MemoryInfo.MemoryDetailsSummary.TotalMemorySizeGB) -join "`n")
                                                                             $row.MemorySizeGB = ((($server.MemoryInfo.MemoryDetails.MemoryData.CapacityMib) | select -Unique | % {$_ / 1024 })  -join ",")
                                                                             $row.MemoryType = ((($server.MemoryInfo.MemoryDetails.memoryData.memorydevicetype)  | ? {$_ -notin "*N*"} | select -Unique) -join ",")
                                                                             $row.HDD = ($hdd.Controllers.PhysicalDrives.Count)
                                                                             $row.HDDSize = ((($hdd.Controllers[0].PhysicalDrives.CapacityGB) | select -Unique) -join ",")
                                                                             $row.HDDType = ((($hdd.Controllers[0].PhysicalDrives.MediaType) | select -Unique) -join ",")
                                                                             $row.HDDModel = ((($hdd.Controllers[0].PhysicalDrives.Model) | select -Unique)-join ",")
                                                                             $row.HDDSN = (($hdd.Controllers[0].PhysicalDrives.SerialNumber) -join ",")
                                                                             $row.NICinfo = (($server.NICInfo.NetworkAdapter.Name) -join ",")
									     $row.PCI = (($pci.PCIDevice.Name) -join ",")
                                                                             $reportyop += $row
                                                                            }
                                                             return $report
                                                            }

$inven = gethpeinventory -serversIlo $serversIlo -credentials $credentials 
$inven | Out-GridView
$inven = $inven | Sort-Object | Get-Unique -AsString

$inven | Export-Csv -UseCulture -Encoding UTF8 -Path <your_path>.csv
