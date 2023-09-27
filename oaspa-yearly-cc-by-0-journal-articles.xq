declare function local:get-latest-article-list($db-name as xs:string*,$year as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article
              let $pub-year := $x//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year
              where $pub-year = $year
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              let $perm-link := lower-case($x//*:article-meta/*:permissions/*:license/*:license_ref)
              let $permissions := if (matches($perm-link,'https?://creativecommons.org/licenses/by/[34].0/?')) then 'cc-by'
                                  else if ($perm-link='http://creativecommons.org/publicdomain/zero/1.0/') then 'cc0'
                                  else 'unknown'
              order by $b
              return <item id="{$id}" permissions="{$permissions}" pub-year="{$pub-year}">{$b}</item>
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

let $year := '2022'
let $articles := local:get-latest-article-list('articles',$year)
return (
  'CC-BY in '||$year||': '||count($articles//*:item[@permissions='cc-by']),
  'CC-0 in '||$year||': '||count($articles//*:item[@permissions='cc0']),
  'Borked?: '||string-join($articles//*:item[@permissions='unknown']/@id,'; '),
  $articles
)