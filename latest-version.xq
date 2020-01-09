let $list-1 := <list>{
              for $x in collection('articles')//*:article
              let $b := $x/base-uri()
              order by $b
              return <item>{$b}</item>
             }</list>
             
return (
  for $x in $list-1/*:item
  let $id := substring-before(substring-after($x,'/articles/elife-'),'-v')
  return
  if (substring-before(substring-after($x/following-sibling::*:item[1],'/articles/elife-'),'-v') = $id) then ()
  else $x/string()
)