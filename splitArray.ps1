# split the array into equal parts

$arr = @()

$arr = @(1,2,3,4,5,6,7,8,9,11,13,45,78,89,99) 
$divider = 4

function arrSplit($array, $div) {
$arrays = @()
$arr = $array
Get-Variable arrsplit* | Remove-Variable
for ($i = 1 ; $i -le [math]::Truncate($arr.count/$divider); $i++) { 
 New-Variable -Name "arrsplit$i" -Value @(for ($j= (($i*$divider - $divider) + 1) ; $j -le ($divider*$i); $j++) { if ($arr[$j-1] -ne $null) {$arr[$j-1]} ;  })} ;
# remainder of the division
if ($arr.Count % $divider -ne 0) {
 New-Variable -Name "arrsplit$([math]::Truncate($arr.count/$divider)+1)" -value @(for ($k = ($arr.Count - ($arr.count % $divider -1)); $k -le $arr.Count; $k++) {if ($arr[$k-1] -ne $null) {$arr[$k-1]}})
}

$arrays = Get-Variable arrsplit*
return $arrays
}

# Example
$arrOfarr = arrSplit -array $arr -div $divider
$arrOfarr[0].Value | % {$_}
