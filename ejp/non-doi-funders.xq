let $article-list := 
  let $list :=  <list>{
    for $x in collection('articles')//*:article[*:body]
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}">{$b}</item>
    }</list>
  return <list>{
    for $x in $list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
return sum(
  for $y in $article-list//*:item
  let $a := collection($y/text())//*:article
  let $count := count($a//*:article-meta//*:funding-group/*:award-group/*:funding-source[not(descendant::*:institution-id)])
  return $count
)