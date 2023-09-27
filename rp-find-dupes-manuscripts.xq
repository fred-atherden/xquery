declare function local:non-distinct-values
  ($seq as xs:anyAtomicType*) as xs:anyAtomicType* {
    for $val in distinct-values($seq)
    return $val[count($seq[. = $val]) > 1]
 };

let $y := file:read-text('/Users/fredatherden/Documents/GitHub/enhanced-preprints-data/manuscripts.txt')

return local:non-distinct-values(
  for $x in (tokenize($y,'^\d{5}:\s*|\n\d{5}:\s*')[.!=''],tokenize($y,':\s.*?\n'))
  let $s := tokenize($x,',')[1]
  return $s
)
