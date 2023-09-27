declare function local:fix-year-date($node){
  let $s := string-length($node)
  return 
  if ($s=4) then string($node)
  else '2022'
};

declare function local:fix-date($node){
  let $s := string-length($node)
  return 
  if ($s=2) then string($node)
  else if ($s=1) then '0'||$node
  else '01'
};

declare function local:get-date($node){
  if ($node/@iso-8601-date) then $node/@iso-8601-date
  else local:fix-year-date($node/*:year[1])||'-'||local:fix-date($node/*:month[1])||'-'||local:fix-date($node/*:day[1])
};

let $list1 := <list>{
              for $x in collection('articles')//*:article
              let $pub-node := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]
              let $isPoa := if ($x/*:body) then false() else true()
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" v="{if ($isPoa) then 'POA' else 'VOR'}" pub="{local:get-date($pub-node)}">{$b}</item>
              }</list>
              
for $d in distinct-values($list1//*:item/@id)
let $items := $list1//*:item[@id = $d]
let $dates := distinct-values($items/@pub)
return if (count($dates) gt 1) then ($d,$items)
