# split the array into equal parts

$arr = @(1,2,3,4,5,6,7,8,9,10)
$z = 3
$arr.count % $z
[math]::Truncate($arr.count/$z)

for ($j=1 ; $j -le [math]::Truncate($arr.count/$z); $j++) {   "NEW: $($j *$z)"
for ($i= ($j*$z - $z)+1 ; $i -le ($z*$j); $i++) { $arr[$i]}
sleep 2
}
# remainder of the division
for ($k = ($arr.Count - $arr.count % $z); $k -le $arr.Count; $k++) {$arr[$k]}
