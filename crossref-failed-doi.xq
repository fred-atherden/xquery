let $csv := csv:parse(file:read-text('/Users/fredatherden/Downloads/10.7554_unres_2023-10.csv'))

for $x in $csv//*:record
(: Pick out the ones with valid DOIs :)
where matches($x/*:entry[1],'^10\.7554/ELIFE\.\d{5}(\.\d{1}|\.\d{3}|\.\d\.sa\d|\.sa\d)?$')
order by number($x/*:entry[2]) descending
return $x/*:entry[1]||' '||$x/*:entry[2]