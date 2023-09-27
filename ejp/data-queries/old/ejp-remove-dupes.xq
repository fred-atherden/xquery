let $db := 'ejp-2021'
let $dois := distinct-values(collection($db)//*:xml//*:production-data-doi)[.!='']

for $doi in $dois
let $xmls := collection($db)//*:xml[descendant::*:production-data-doi=$doi]
let $max-stages := max(
    for $x in $xmls 
    return count($x//*:history/*:stage)
)
    for $x in $xmls
    let $stage-count := count($x//*:history/*:stage)
    where $stage-count != $max-stages
    return db:delete($db,substring-after($x/base-uri(),($db||'/')))