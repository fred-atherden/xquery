let $db := 'articles'
let $article-store := '/Users/fredatherden/Documents/GitHub/elife-article-xml/articles'
let $list := <list>{
  for $x in collection($db)//*:article
  return <item>{$x/base-uri()}</item>
}</list>

for $x in file:list($article-store)
let $uri := ('/'||$db||'/'||$x)
let $xml := doc(concat($article-store,'/',$x))
return
if (not(matches($x,'\.xml$'))) then ()
else if ($uri = $list//*:item/text()) then ()
else db:replace($db,$x,$xml)