for $x in collection('articles')//*:contrib-group[not(@content-type)]
let $list := 
<list>{
  for $aff in $x/*:aff
  let $i := $aff/*:institution[not(@content-type)]
  return 
  if ($i=$aff/preceding-sibling::*:aff/institution[not(@content-type)]) then <item>{$aff}</item>
  else ()
}</list>
return 
if (count($list//*:item)>4) then $x/base-uri()
else ()