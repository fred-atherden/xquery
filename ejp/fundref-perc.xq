let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[*:body and //*:funding-group[*:award-group]]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}" pub-year="{$pub-year}" base="{$b}">{
     for $y in $x//*:article-meta//*:funding-group//*:funding-source//*:institution-wrap
     return if ($y/*:institution-id[@institution-id-type='FundRef']) then 
            <funder doi="{$y/*:institution-id[@institution-id-type='FundRef']}">{$y/*:institution/data()}</funder>
            else <funder>{$y/*:institution/data()}</funder>
    }</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $year in distinct-values($list//*:item/@pub-year)
let $no-doi := count($list//*:item[@pub-year=$year]/funder[not(@doi)])
let $doi := count($list//*:item[@pub-year=$year]/funder[@doi])
let $per := ($no-doi div ($no-doi + $doi)) * 100
return ($year||'	'||$per||'	'||$no-doi||'	'||$doi)