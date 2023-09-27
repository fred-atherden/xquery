declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}">{$b}</item>
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
let $vals := ('competing-interest','author-contribution','ethics-information')

return distinct-values(
  for $x in $latest-articles//*:item
  let $article := collection($x/text())
  let $id := $x/@id
  let $first-digit := number(substring($id,1,1))
  where $first-digit=(5,6,7) and $article//*:article[*:body]//*:fn-group[not(@content-type=$vals)]
  order by $id descending
  return $id
)