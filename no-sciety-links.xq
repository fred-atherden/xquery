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

let $items := distinct-values(
  for $item in $latest-articles//*:item
  let $x := collection($item/text())
  where ($x//*:sub-article[@id="sa0" and not(descendant::*:related-object)])
  let $id := substring-before(substring-after($item/text(),'elife-'),'-v') 
  let $preprint := $x//*:article-meta//*:event//*:self-uri/@*:href
  where $preprint
  let $sciety := 'https://sciety.org/articles/activity/'||substring-after($preprint,'.org/')
  order by $id descending
  return $id||' '||$sciety
)

return (
  ('Search in Gmail: {'||string-join(for $x in $items return substring-before($x,' '),' ')||'} and "Decision letter JATS posted" and "<related-object" '),
$items)