declare variable $us-uk-list := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/us-uk-list.xml');


for $xml in collection('articles')//*:article[*:body]
let $article-id := $xml//*:article-id[@pub-id-type="publisher-id"]/text()
return 
if (matches($article-id,'^44')) then 
 (
let $text := replace(string-join(
  for $x in $xml/(*:front/*:article-meta//(*:article-title|*:abstract//*:p|*:custom-meta/*:meta-value)|
                              *:body//(*:p|*:title|*:th|*:td)|
                              *:back//(*:ack//*:p|*:app//*:p|*:title|*:th|*:td)
                              )
  return $x/data()
  ,' '),'[^\p{L}\s]','')

let $tokens := tokenize($text,' ')

let $style-list := <list>{
  for $x in $tokens
  return 
  if ($x = $us-uk-list//*:item/@us/string()) then <us>{$x}</us>
  else if ($x = $us-uk-list//*:item/@uk/string()) then <uk>{$x}</uk>
  else ()
  }</list>
  
let $us := count($style-list//*:us)
let $uk := count($style-list//*:uk)

  return 
  if (($us gt 0) and ($uk gt 0)) then $xml/base-uri()
  else ()
  
)

else ()