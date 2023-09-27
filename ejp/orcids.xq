let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[*:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    let $ejp-base := ('/ejp-export/'||$id||'.xml')
    order by $b
    return 
    <item id="{$id}" pub-year="{$pub-year}" ejp="{$ejp-base}">{$b}</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $year in distinct-values($list//*:item/@pub-year)
  let $items := $list//*:item[@pub-year=$year]
  let $auth-count :=  sum(
    for $x in $items
    return count(collection($x/text())//*:article-meta//*:contrib[@contrib-type="author" and not(ancestor::*:collab)])
  )
  let $v-orcids := sum(
                    for $x in $items
                    return count(collection($x/text())//*:article-meta//*:contrib[@contrib-type="author"]/*:contrib-id[@contrib-id-type="orcid"])
                  )
  let $e-orcids := sum(
                  for $x in $items
                  return 
                  try {count(collection($x/@ejp)//*:contrib[@contrib-type="author" and  ext-link[@ext-link-type="orcid"]])}
                  catch * {0}
  )
  return ($year||'	'||count($items)||'	'||$auth-count||'	'||$e-orcids||'	'||$v-orcids)