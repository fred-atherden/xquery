let $list-1 := <list>{
              for $x in collection('articles')//*:article
              let $b := $x/base-uri()
              order by $b
              return <item>{$b}</item>
             }</list>
 
 let $list-2 := 
 <list>{
  for $x in $list-1/*:item
  let $id := substring-before(substring-after($x,'/articles/elife-'),'-v')
  return
  if (substring-before(substring-after($x/following-sibling::*:item[1],'/articles/elife-'),'-v') = $id) then ()
  else <item id="{$id}">{$x/string()}</item>
 }</list>
 
 let $list-3 := doc('/Users/fredatherden/Desktop/list3.xml')
 
for $x in $list-2//*:item
let $id := $x/@id
return
  if ($list-3//*:item[.=$id]) then ()
  else (
    let $article := collection($x/text())//*:article
    return if ($article//*:supplementary-material[contains(lower-case(*:label[1]),'source code')]) then ($x||' code file - '||string-join(for $y in $article//*:supplementary-material[contains(lower-case(*:label[1]),'source code')] return $y/*:label[1] ,' '))
    else if ($article//*:ext-link[contains(@*:href,'elifesciences-publications')])  then ($x||' - repo link')
    else if (contains(lower-case($article),'markdown')) then ($x||' - mentions markdown')
    else if (contains(lower-case($article),'notebook')) then ($x||' - mentions notebook')
    else ()
  )

