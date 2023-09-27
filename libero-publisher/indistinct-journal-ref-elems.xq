declare function local:non-distinct-values
  ( $seq as xs:anyAtomicType* )  as xs:anyAtomicType* {

   for $val in distinct-values($seq)
   return $val[count($seq[. = $val]) > 1]
 } ;

for $x in collection('ijm')//*:element-citation[@publication-type="journal"]
let $id := $x/parent::*:ref/@id
let $values := string-join(local:non-distinct-values(for $y in $x/*[not(name()='pub-id')] return $y/name()),', ')
return 
if ($values='') then ()
else ($values||' - '||$id||' - '||$x/base-uri())