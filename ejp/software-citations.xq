let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[@article-type="research-article" and *:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $code-ref-count := count($x//*:element-citation[@publication-type="software"])
    let $code-cite-count := sum(for $z in $x//*:element-citation[@publication-type="software"]
                                let $id := $z/parent::*:ref/@id
                                return count($z/ancestor::*:article//*:xref[@rid=$id]))
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return 
    <item id="{$id}" pub-year="{$pub-year}" base="{$b}" 
          code-cite-count="{$code-cite-count}" code-ref-count="{$code-ref-count}"/>
  }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 

return (2012||'	'||0||'	'||0||'	'||0,
for $year in distinct-values($list//*:item/@pub-year)
let $items := $list/*:item[@pub-year=$year]
let $citations := sum($items/@code-cite-count)
let $refs := sum($items/@code-ref-count)
return number($year) + 1||'	'||count($items)||'	'||$citations||'	'||$refs
)
