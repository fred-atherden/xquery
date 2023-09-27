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

declare function local:median($vals){
  let $values := for $x in $vals order by number($x) ascending return $x
  let $count := count($values)
  let $median-number :=  if (($count mod 2)=1) then (($count div 2)+0.5)
                         else (
                            ($count div 2),
                            (($count div 2)+1)
                         )

  let $median := if (count($median-number)=1) then (
                              for $x at $p in $values
                              where $p=$median-number
                              return $x
                                              )
                 else (sum(for $x at $p in $values
                           where $p=$median-number
                           return number($x)) div 2)

  return $median
};

let $list1 := <list>{
              for $x in collection('articles')//*:article[@article-type="research-article"]
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              where $type != 'feature article'
              let $acc-node := $x//*:article-meta/*:history/*:date[@date-type="accepted"]
              let $rec-node := $x//*:article-meta/*:history/*:date[@date-type="received"]
              let $pub-node := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" rec="{local:get-date($rec-node)}" acc="{local:get-date($acc-node)}" pub="{local:get-date($pub-node)}" pub-year="{$pub-node/*:year[1]}">{$b}</item>
              }</list>
 
let $articles :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                  }</list>


for $year in distinct-values($articles//*:item/@pub-year)
let $vals := for $x in $articles/*:item[@pub-year = $year]
             let $acc-diff := xs:date($x/@pub) - xs:date($x/@acc)
             where $acc-diff gt xs:dayTimeDuration("P3D")
             return number(replace(string(xs:date($x/@pub) - xs:date($x/@rec)),'[^\d]',''))
let $median := local:median($vals)
return $year||' '||$median