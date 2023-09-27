let $list1 := <list>{
              for $x in collection('articles')//*:article
              let $iso-pub :=  for $y in $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]
                               return ($y/*:year||'-'||$y/*:month||'-'||$y/*:day)
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" pub="{$iso-pub}">{$b}</item>
             }</list>
 
let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
}</list>

for $x in $list2//*:item
let $a := collection($x/text())//*:article
where not($a/*:body)
order by $x/@pub
return $x/text()||' '||$x/@pub