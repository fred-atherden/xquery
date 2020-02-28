let $list-1 := 
<list>{
 for $x in collection('articles')//*:article
 let $b := $x/base-uri()
 order by $b
 return <item>{$b}</item>
}</list>

let $latest-list := 
<list>{
 for $x in $list-1/*:item
 let $id := substring-before(substring-after($x,'/articles/elife-'),'-v')
 return
 if (substring-before(substring-after($x/following-sibling::*:item[1],'/articles/elife-'),'-v') = $id) then ()
 else <item>{$x}</item>
}</list>


let $values := distinct-values(
  for $x in collection('articles')//*:article[base-uri()=$latest-list//*:item/data()]//*:article-meta//(*:article-title|*:kwd)
  let $l := lower-case($x)
  return
  if (matches($l,' aging| ageing| longevity| lifespan| geroscience|^aging|^ageing|^longevity|^lifespan|^geroscience')) then $x/base-uri()
  else ()
)

let $list-2 := 
<list>{for $y in $values
return <item>{$y}</item>}</list>

let $final-ids := 
for $article in collection('articles')//*:article
  let $base := $article/base-uri()
 return
  if ($base = $list-2//*:item/string()) then 
     let $subj1 := $article//*:article-meta/descendant::*:subj-group[@subj-group-type="heading"][1]/*:subject
     let $subj2 := $article//*:article-meta/descendant::*:subj-group[@subj-group-type="heading"][2]/*:subject
     let $id := $article/*:front/*:article-meta/*:article-id[@pub-id-type="publisher-id"]
     let $unallowed-subjs := ('neuroscience','plant biology','evolutionary biology')
     order by $id
     return (
        if ((lower-case($subj1)=$unallowed-subjs) and not($subj2)) then ()
        else $id
      )
  else ()
  
 
  
  for $id in $final-ids
  order by $id
  return ("                - "||"'"||$id||"'")  
  