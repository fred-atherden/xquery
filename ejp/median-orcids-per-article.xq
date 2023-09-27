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
  
let $values := for $y in $article-list//*:item
  let $a := collection($y/text())//*:article
  let $count := count($a//*:article-meta//*:contrib[@contrib-type="author" and contrib-id[@contrib-id-type="orcid"]])
  order by $count
  return $count

let $count := count($values)

let $median-number :=  
    if (($count mod 2)=1) then (($count div 2)+0.5)
    else (($count div 2),(($count div 2)+1))

let $median := 
    if (count($median-number)=1) then (for $x in $values[position()=$median-number] return $x)
    else (sum(for $x in $values[position()=$median-number] return $x) div 2)
    
return $median