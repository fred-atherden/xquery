let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[@article-type=("research-article","review-article") and *:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}" pub-year="{$pub-year}">{$b}</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $year in distinct-values($list//*:item/@pub-year)
let $items := $list//*:item[@pub-year = $year]
let $articles :=  for $x in $items return collection($x/text())//*:article
let $rrid-count := count(for $x in $articles where $x//*:ext-link[matches(lower-case(@*:href),'^https?://identifiers.org/RRID|https?://scicrunch.org/resolver/')] return $x)

return 
$year||'	'||count($articles)||'	'||$rrid-count