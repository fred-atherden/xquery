declare function local:get-latest-prc-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[//*:article-meta//*:custom-meta/*:meta-value='prc']
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              let $rp-pub-date := $x//*:article-meta/*:pub-history/*:event[contains(*:event-desc[1],'published as a reviewed preprint')]/*:date/@iso-8601-date
              order by $b
              return <item id="{$id}" rp-pub-date="{$rp-pub-date}">{$b}</item>
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

local:get-latest-prc-article-list('articles')