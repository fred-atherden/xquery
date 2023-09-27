declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[@article-type="research-article" and *:body]
              let $pub-year := $x//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              let $has-kr-table := if ($x//*:table-wrap[contains(@id,'keyresource')]) then true() else false()
              let $has-trf := if ($x//*:supplementary-material[matches(lower-case(*:label[1]),'transparent|mdar')]) then true() else false()
              order by $b
              return <item id="{$id}" pub-year="{$pub-year}" has-kr-table="{$has-kr-table}" has-trf="{$has-trf}">{$b}</item>
              }</list>
 
  let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                  }</list>

  return $list2
};

let $latest-articles := local:get-latest-article-list('articles')

return (
  'year	KRT percentage	TRF/MDAR percentage',
  for $year in distinct-values($latest-articles//*:item/@pub-year)
  order by $year ascending
  let $arts := $latest-articles//*:item[@pub-year=$year]
  let $kr-percent := round((count($arts[@has-kr-table="true"]) div count($arts)) * 100)
  let $trf-percent := round((count($arts[@has-trf="true"]) div count($arts)) * 100)
  return $year||'	'||$kr-percent||'%	'||$trf-percent||'%' 
)