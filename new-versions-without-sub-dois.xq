(: New versions without sub-dois when their previous versions did :)

let $list := <list>{for $x in collection('articles')//*:article
let $has-d := if ($x/descendant::*:object-id) then 'yes' else 'no'
return <item id="{substring-before(substring-after($x/base-uri(),'elife-'),'-v')}" version="{substring-before(substring-after($x/base-uri(),'-v'),'.xml')}" sub-doi="{$has-d}">{$x/base-uri()}</item>}</list>

for $x in $list//*:item[@sub-doi="no"]
let $id := $x/@id
let $v := number($x/@version)
let $others := $x/(preceding-sibling::*:item[@sub-doi="yes" and (@id = $id) and number(@version) lt $v]|following-sibling::*:item[@sub-doi="yes" and (@id = $id) and number(@version) lt $v])
return $others