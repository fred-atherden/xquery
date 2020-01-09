let $values := distinct-values(
  for $x in collection('articles')//*:article[*:body]//*:article-meta//(*:article-title|*:kwd)
  let $l := lower-case($x)
  let $doi := $x/ancestor::*:article-meta/*:article-id[@pub-id-type="doi"]
  return
  if (matches($l,' aging| ageing| longevity| lifespan| geroscience|^aging|^ageing|^longevity|^lifespan|^geroscience')) then $x/base-uri()
  else ()
)

let $list := 
<list>{for $y in $values
return <item>{$y}</item>}</list>


let $csv := 
<csv>{
  for $x in collection('articles')//*:article[*:body]
  let $subj1 := $x//*:article-meta/descendant::*:subj-group[@subj-group-type="heading"][1]/*:subject
  let $subj2 := $x//*:article-meta/descendant::*:subj-group[@subj-group-type="heading"][2]/*:subject
  let $base := $x/base-uri()
  let $meta := $x/*:front/*:article-meta
  let $title := $meta//*:article-title
  let $kwds := $meta/*:kwd-group[@kwd-group-type="author-keywords"]
  let $doi := ('http://doi.org/'||$meta/*:article-id[@pub-id-type="doi"])
  let $unallowed-subjs := ('neuroscience','plant biology','evolutionary biology')
  return
  if ($base = $list//*:item/string()) then 
  if ((lower-case($subj1)=$unallowed-subjs) and not($subj2)) then ()
  else (
  <record>
  <entry>{$doi}</entry>
  <entry>{$title/data()}</entry>
  {for $z in ($subj1|$subj2) return <entry>{$z/data()}</entry>}
  {for $y in $kwds/*:kwd return <entry>{$y/data()}</entry>}
  </record>)
}
  </csv>
  
  
  return $csv