let $x := doc('/Users/fredatherden/Documents/GitHub/jats-support/src/support.sch')

return copy $copy := $x
modify(
  
  for $x in $copy//(*:assert|*:report)
  let $r := $x/ancestor::*:pattern/@id
  let $pos := count($x/ancestor::*:pattern//*[local-name() = $x/local-name()]) - count($x/following::*[(local-name() = $x/local-name()) and (ancestor::*:pattern/@id = $r)])
  return
  insert node attribute id {concat($x/ancestor::*:pattern/@id,'-',$x/local-name(),'-',$pos)} as last into $x
  
  
  
)

return 

file:write('/Users/fredatherden/Desktop/support.sch',$copy, map{'indent':'no'})