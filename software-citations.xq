declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[*:body]
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")]/*:year
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              where not($type=('insight','editorial','correction','retraction'))
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

for $year in distinct-values($latest-articles//*:item/@pub-year)
order by $year
let $articles := for $x in $latest-articles//*:item[@pub-year=$year] return collection($x/text())/*:article
let $article-count := count($articles)
let $software-refs := $articles//*:ref[*:element-citation[@publication-type="software"]]
let $citation-count := sum(for $x in $software-refs return count($x/ancestor::*:article//*:xref[@rid=$x/@id and @ref-type="bibr"]))
return string-join(
  ($year,
  $article-count,
  count($software-refs),
  $citation-count)
  ,'	')