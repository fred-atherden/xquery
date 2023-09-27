let $csv := csv:parse(file:read-text('/Users/fredatherden/Desktop/Book1.csv'))

let $new := copy $copy := $csv
modify(
  for $x in $copy//*:record
  let $pos := count($x/parent::*:csv/*:record) - count($x/following-sibling::*:record)
  return insert node attribute {'id'} {$pos} into $x
)
return $copy


for $x in $new//*:record
order by 1 - number($x/@id/string())
return 
($x/entry[1]||'	'||$x/entry[2]||'	'||$x/entry[3]||'	'||$x/entry[4])