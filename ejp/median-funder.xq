declare function local:median($values as xs:integer*) as xs:float{
  let $count := count($values)
  let $median-number :=  if (($count mod 2)=1) then (($count div 2)+0.5)
                         else (
                            ($count div 2),
                            (($count div 2)+1)
                         )

  let $median := if (count($median-number)=1) then (
                              for $x in $values[position()=$median-number]
                              return $x
                                              )
                 else (sum(for $x in $values[position()=$median-number]
                           return $x) div 2)

  return $median
};

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
  
for $year in distinct-values($list//*:item/@pub-year)
let $items := $list//*:item[@pub-year=$year]
let $values := for $x in $items let $count := count($x//*:funder) order by $count return $count
let $median := local:median($values)
return ($year||'	'||count($items)||'	'||$median)