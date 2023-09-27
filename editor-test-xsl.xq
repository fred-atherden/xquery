declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[@article-type="article-commentary"]
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

declare variable $base := '/Users/fredatherden/Desktop/editor/';
declare variable $kriya2editor := doc('/Users/fredatherden/Documents/xsl/kriya2editor.xsl');
declare variable $editor2kriya := doc('/Users/fredatherden/Documents/xsl/editor2kriya.xsl');

let $list := local:get-latest-article-list('articles')

for $x in $list//*:item
let $number := number($x/@id)
let $filename := substring-after($x/text(),'articles/')
return if ($number lt 35663) then ()
else (
  let $article := collection($x/text())
  let $editor-version := xslt:transform($article,$kriya2editor)
  let $kriya-version := xslt:transform($editor-version,$editor2kriya)
  return (
    file:write(($base||'original/'||$filename),$article),
    file:write(($base||'editor/'||$filename),$editor-version),
    file:write(($base||'kriya/'||$filename),$kriya-version)
  )
)