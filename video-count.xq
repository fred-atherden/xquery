declare function local:get-date($node){
  if ($node/@iso-8601-date) then $node/@iso-8601-date
  else local:fix-year-date($node/*:year[1])||'-'||local:fix-date($node/*:month[1])||'-'||local:fix-date($node/*:day[1])
};

declare function local:fix-date($node){
  let $s := string-length($node)
  return 
  if ($s=2) then string($node)
  else if ($s=1) then '0'||$node
  else '01'
};

declare function local:fix-year-date($node){
  let $s := string-length($node)
  return 
  if ($s=4) then string($node)
  else '2023'
};

declare function local:get-yearly-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[*:body]
              let $pub-date := $x//*:article-meta/*:pub-date[@publication-format="electronic"][1]
              let $iso-pub-date := local:get-date($pub-date)
              let $one-year-ago := (current-date() - xs:yearMonthDuration("P1Y"))
              where $one-year-ago le xs:date($iso-pub-date)
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              let $video-count := count($x//*:media[@mimetype="video"])
              order by $b
              return <item id="{$id}" pub-date="{$iso-pub-date}" video-count="{$video-count}">{$b}</item>
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

let $articles := local:get-yearly-article-list('articles')
let $article-count := count($articles//*:item)
let $video-count := sum(for $x in $articles//*:item return number($x/@video-count))
return ($article-count,
        $video-count,       
  $video-count div $article-count
)