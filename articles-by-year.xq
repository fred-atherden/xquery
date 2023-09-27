declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $pub-year := $x//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" pub-year="{$pub-year}">{$b}</item>
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

let $pub-years := distinct-values(for $x in collection('articles')//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year order by 1-number($x) return $x)

for $y in $pub-years
return $y||' - '||count($latest-articles//*:item[@pub-year = $y])