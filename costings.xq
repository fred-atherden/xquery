declare function local:year-cost($c,$r) {
   let $tot-cost := if ($c le 2000) then (11042 * 12) else (11042 * 12) + (($c - 2000) * 67)
   return $tot-cost + 2400 + 600 + (($r * 25) * 2.25)
};

let $list1 := <list>{
              for $x in collection('articles')//*:article
              let $p := $x//*:article-meta/*:pub-date[@pub-type="collection"]/*:year
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              where $p = '2021'
              order by $b 
              return <item id="{$id}" type="{$type}">{$b}</item>
             }</list>
 
let $list :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
}</list>

let $res := ('research article','short report','tools and resources','research advance','review article')
let $total := count($list//*:item)
let $res-count := count($list/*:item[@type=$res])
let $note := sum(for $x in distinct-values($list/*:item/@type[not(.=($res,'feature article'))]) return count($list//*:item[@type=$x]))
let $feat := count($list//*:item[@type='feature article'])
let $t-cost := local:year-cost($total,$res-count)
let $d-cost := local:year-cost($res-count,$res-count) + ($note * 5) + ($feat * 30)

return ('Total: '||$total||' '||$t-cost,
        'With latex charges '||$t-cost + (($total div 10)*10),
        'Treated differently: '||$d-cost,
        'Diff with latex charges '||$d-cost + (($total div 10)*10),
        'Research: '||$res-count,
        'Notices: '|| $note,
        'Feature articles: '|| $feat,
        $list)