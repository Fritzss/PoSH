$user = "<user>"
$pass = Get-Content "<path_to_password>"| ConvertTo-SecureString
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass

function Connect-RDP {
 
  param (
    [Parameter(Mandatory=$true)]
    $ComputerName,
 
    [System.Management.Automation.Credential()]
    $Credential
  )
  $cfg =  "<path_to_rdp_file>.rdp"
  # take each computername and process it individually
  $ComputerName | ForEach-Object {
 
    # if the user has submitted a credential, store it
    # safely using cmdkey.exe for the given connection
    if ($PSBoundParameters.ContainsKey('Credential'))
    {
      # extract username and password from credential
      $User = $Credential.UserName
      $Password = $Credential.GetNetworkCredential().Password
 
      # save information using cmdkey.exe
      cmdkey.exe /generic:$_ /user:$user /pass:$password
    }
 
    # initiate the RDP connection
    # connection will automatically use cached credentials
    # if there are no cached credentials, you will have to log on
    # manually, so on first use, make sure you use -Credential to submit
    # logon credential
      mstsc.exe $cfg /v $_ /f 
  }
}

$rdp = Get-Content <file_witch_IP_hosts>

$rdp | % {if ((Test-NetConnection -Port 3389 $_).TcpTestSucceeded) { Out-File -filepath "<path>success.log" -InputObject $_ -Append;
                                                                     Connect-RDP -ComputerName $_ -Credential $credentials
                                                                     }
                                                                     else { Out-File -filepath "<path>fail.log" -InputObject $_ -Append}
                                                                     }
