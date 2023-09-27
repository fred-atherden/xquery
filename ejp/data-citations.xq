let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[@article-type="research-article" and *:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $data-ref-count := count($x//(*:element-citation[@publication-type="data"]|*:related-object[@content-type=('generated-dataset','existing-dataset')]))
    let $data-cite-count := sum(for $z in $x//*:element-citation[@publication-type="data"]
                                let $id := $z/parent::*:ref/@id
                                return count($z/ancestor::*:article//*:xref[@rid=$id]))
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return 
    <item id="{$id}" pub-year="{$pub-year}" base="{$b}" 
          data-cite-count="{$data-cite-count}" data-ref-count="{$data-ref-count}"/>
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
let $citations := sum($items/@data-cite-count)
let $refs := sum($items/@data-ref-count)
return number($year) + 1||'	'||count($items)||'	'||$citations||'	'||$refs
)
