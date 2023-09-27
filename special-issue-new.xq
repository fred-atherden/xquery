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

let $csv := 
<csv>{
  for $x in collection('articles')//*:article[base-uri()=$latest-list//*:item/data()]
  let $title := $x//*:article-meta/*:title-group/*:article-title/string()
  let $doi := ('http://doi.org/'||$x//*:article-meta/*:article-id[@pub-id-type="doi"])
  let $abstract := lower-case($x//*:article-meta/*:abstract[not(@*)][1])
  let $msas := lower-case(string-join(
                  for $y in $x//*:article-meta//*:subj-group[@subj-group-type="heading"]/*:subject
                  return $y/string()
               , ' - '))
  let $msa-record := 
                  for $y in $x//*:article-meta//*:subj-group[@subj-group-type="heading"]/*:subject
                  return <entry>{$y/string()}</entry>
  let $record := <record><entry>{$doi}</entry><entry>{$title}</entry>{$msa-record}</record>
  return
  if (contains($msas,'evolutionary biology') or contains($msas, 'human biology and medicine') or contains($msas, 'genetics and genomics') or contains($msas, 'microbiology and infectious disease') or contains($msas, 'ecology or epidemiology and global health')) then (
    if (matches(lower-case($title),'anti\-?biotic resistance|anti\-?biotic evolution|anti\-?microbial resistance|anti\-?microbial evolution|pleiotropy|evolutionary medicine')) then $record
    else if (matches($abstract,'anti\-?biotic resistance|anti\-?biotic evolution|anti\-?microbial resistance|anti\-?microbial evolution|pleiotropy|evolutionary medicine')) then $record
    else ()
    )
  else ()
}</csv>


return file:write('/Users/fredatherden/Desktop/special-issue.csv',$csv, map{'method':'csv'})