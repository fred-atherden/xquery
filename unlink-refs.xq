for $x in collection('plos-xml')//*:article
let $r := count(for $y in $x//*:ref
                let $id := $y/@id
                return if ($y/ancestor::*:article//*:xref[@rid = $id]) then ()
                else $x
            )
return
if ($r = 0) then ()
else $r