let $xml :=  doc('/Users/fredatherden/Desktop/elife-42463-v1.xml')

let $copy := copy $copy1 := $xml
modify(
  for $x in $copy1//*:contrib-group[@content-type="collab-list"]//*:aff
  let $id := generate-id($x)
  return insert node attribute id {$id} as first into $x
)


return copy $copy2 := $copy1
modify(
  for $x in $copy2//*:contrib-group[@content-type="collab-list"]//*:contrib
  return replace value of node $x/@contrib-type with 'collaborator',
  
  for $y in $copy2//*:contrib-group[@content-type="collab-list"]//*:contrib//*:aff
  return 
  (replace node $y with <xref ref-type="aff" rid="{$y/@id}"/>,
   insert node $y as last into $y/ancestor::*:contrib-group[@content-type="collab-list"])
  
)
return $copy2

return $copy