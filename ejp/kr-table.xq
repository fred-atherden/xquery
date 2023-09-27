let $types := ('research article', 'research advance', 'short report', 'tools and resources', 'research communication', 'replication study')

let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[*:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $type := lower-case($x//*:article-meta/*:article-categories[1]/*:subj-group[@subj-group-type="display-channel"][1]/*:subject[1])
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    where $type = $types
    return <item id="{$id}" pub-year="{$pub-year}">{$b}</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 

return (2012||'	'||0||'	'||0||'	'||0,
for $year in distinct-values($list//*:item/@pub-year)
let $items := $list//*:item[@pub-year = $year]
let $articles :=  for $x in $items return collection($x/text())//*:article
let $kr-table-count := count(for $a in $articles where $a//*:table-wrap[contains(lower-case(*:label[1]),'key resource')] return $a)
let $kr-supp := count(for $a in $articles where $a//*:supplementary-material[contains(lower-case(*:caption[1]/*:title[1]),'key resource')] return $a)
return number($year) + 1||'	'||count($articles)||'	'||$kr-table-count||'	'||$kr-supp
)
