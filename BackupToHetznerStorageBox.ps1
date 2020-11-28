if (Test-Path Z:\) { net use z: \\<user>.your-storagebox.de\backup<or sub account > /user:user pass /PERSISTENT:YES}
#from which folder in folder c:\backup to take files
$pathALL="lt","lt-test"
$pathALL | % {if (!(Test-Path z:\$_)) {New-Item -Path z:\$_ -ItemType Directory}}
foreach ($_pathALL in $pathALL) {
#password
$pass=<password_arhive>
#path_to_backup
$path_back="Z:\$_pathALL"
$path_local_back = "C:\BACKUP\$_pathALL"
$het=@()
$het=(Get-ChildItem "$path_back\").BaseName
$locBack=@()
$locBack=(Get-ChildItem "$path_local_back\").BaseName
$tmpBack= $locBack |? {$het -notcontains $_ }
#use 7-zip
$tmpBack | % {&"C:\Program Files\7-Zip\7z.exe" a -tzip -p"$pass" -ssw -r0 "$path_back\$_.zip" "$path_local_back\$_.bak"}
#$tmpBack |% {copy-item -force $path_local_back\$_ -Destination $path_back}

#
$dayClear=7
#check file date
$date = (Get-Date).AddDays(—$dayClear )
$check_backup=(Get-childItem $path_back -Recurse).LastWriteTime
if ($check_backup -gt $date){
# remove fail old $dayClear ? 
            Get-ChildItem -Path $path_back -Recurse| where {!$_.PSIsContainer} |
                foreach {
                            if ($_.LastWriteTime -lt $date) {
                                    # for test -whatif
                                    # if correct work - remove -whatif
                                    $_ >> $path_local_back\"logs.txt";
                                    Remove-Item -Exclude "*.iso","*.txt" $path_back\$_ -WhatIf ;
                                                               }
                        }
             }
