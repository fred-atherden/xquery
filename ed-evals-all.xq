declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[*:sub-article[@article-type="editor-report"]]
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



let $articles :=  local:get-latest-article-list('articles')

let $records := for $x in $articles//*:item
                let $article :=  collection($x/text())
                let $title := $article//*:article-meta//*:article-title/data()
                let $pub-date := local:get-date($article//*:article-meta/*:pub-date[@date-type=("publication","pub")][1])
                let $content := <entry>{$article//*:sub-article[@article-type="editor-report"]//*:p/data()}</entry>
                order by $pub-date descending
                return <record>
                <entry>{('https://doi.org/10.7554/eLife.'||$x/@id)}</entry>
                <entry>{$title}</entry>
                <entry>{$pub-date}</entry>
                {$content}
                </record>
                
let $csv := <csv><record><entry>DOI</entry><entry>Title</entry><entry>Pub date</entry><entry>Editor's evaluation</entry></record>{$records}
</csv>

return file:write('/Users/fredatherden/Desktop/ed-summaries.csv',$csv, map{'method':'csv'})