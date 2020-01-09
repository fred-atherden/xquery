let $base := '/Users/fredatherden/Desktop/lists/'
let $ijm := doc(concat($base,'ijm-att-list.xml'))/*:list

let $elife := doc(concat($base,'elife-att-list.xml'))/*:list
let $biorxiv := doc(concat($base,'biorxiv-att-list.xml'))/*:list
let $wellcome := doc(concat($base,'wellcome-att-list.xml'))/*:list
let $gates := doc(concat($base,'gates-att-list.xml'))/*:list
let $f1000 := doc(concat($base,'f1000-att-list.xml'))/*:list

for $x in $biorxiv//*:attribute
let $t := $x/text()
return
if ($t = $ijm//*:attribute/text()) then ()
else if ($t = $wellcome//*:attribute/text()) then ()
else if ($t = $gates//*:attribute/text()) then ()
else if ($t = $f1000//*:attribute/text()) then ()
else $x


