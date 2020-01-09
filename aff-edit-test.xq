let $xml := doc('/Users/fredatherden/Desktop/elife-49920-vor-r2/elife-49920.xml')

let $new-xml := copy $copy := $xml
modify(
  for $x in $copy//*:contrib-group[not(@content-type)]//*:aff
  let $dept := $x/*:institution[@content-type="dept"]
  let $inst := $x/*:institution[not(@content-type)]
  return if ($inst = 'University of Kentucky') then (
    replace node $inst with <institution>{concat($dept,', ',$inst)}</institution>,
    delete node $dept
  )
  else ()
)
return $copy

return file:write('Desktop/elife-49920.xml',$new-xml,map{'indent':'no'})