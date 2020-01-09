let $list := 
<list>{
  for $x in collection('articles')//*:article
let $article-id := $x//*:article-id[@pub-id-type="publisher-id"]/text()
let $folder := concat('/articles/elife-',$article-id,'-v')
let $v-no := number(substring-before(substring-after($x/base-uri(),$folder),'.xml'))
let $count := count(collection('articles')//*:article[descendant::*:article-id[@pub-id-type="publisher-id"]/text() = $article-id])
return if ($count = $v-no) then <item id="{$x/base-uri()}"/>
else ()
}</list>

for $x in collection('articles')//*:article
let $b := $x/base-uri()
let $c := count($x//*:contrib-group[not(@content-type="section")]/*:contrib)
return if ($b = $list//*:item/@id) then
  if ($c = 1) then () 
  else if ($x//*:contrib[not(@corresp="yes")and not(descendant::*:xref[@ref-type="corresp"])]//*:email) then $x//article-id[@pub-id-type="publisher-id"]/text()
  else ()
else ()