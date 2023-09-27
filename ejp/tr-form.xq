let $types := ('research article','short report','research advance','research communication','tools and resources','scientific correspondence','replication study','review article')

let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[*:body]
    let $type := lower-case($x//*:article-meta/*:article-categories[1]/*:subj-group[@subj-group-type="display-channel"][1]/*:subject[1])
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    where $type = $types
    return <item id="{$id}" pub-year="{$pub-year}" type="{$type}">{$b}</item>
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
let $tr-count := count(for $x in $articles where $x//*:supplementary-material[matches(lower-case(*:label[1]),'[Tt]ransparent reporting form|[Tt]ransparent form|[Tt]ransparent reporting')] return $x/base-uri())

return 
$year||'	'||count($articles)||'	'||$tr-count
