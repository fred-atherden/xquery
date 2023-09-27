let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[*:body and //*:funding-group[*:award-group]]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}" pub-year="{$pub-year}" base="{$b}">{
     for $y in $x//*:article-meta//*:funding-group//*:funding-source//*:institution-wrap[*:institution-id[@institution-id-type='FundRef']]
     return <funder doi="{$y/*:institution-id[@institution-id-type='FundRef']}">{$y/*:institution/data()}</funder>
    }</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $d in distinct-values($list//*:item/*:funder/@doi)
let $name := $list/descendant::*:item[*:funder[@doi=$d]][1]/*:funder[@doi=$d][1]/text()
let $link := ('=HYPERLINK("'||$d||'","'||$name||'")')
let $count := count($list//*:item[*:funder[@doi=$d]])
order by $count descending
return ($link||'	'||$count)