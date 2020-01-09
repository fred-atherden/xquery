distinct-values(for $x in collection('articles')//*:article[(descendant::*:body) and descendant::*:article-meta/*:funding-group]
let $article-id := $x//*:article-id[@pub-id-type="publisher-id"]/text()
let $f := $x//*:article-meta/*:funding-group

          
return  
  for $y in $f/*:award-group
          let $i := $y//*:institution/data()
          let $i-id := $y//*:institution-id/data()
          let $a-id := $y/*:award-id/data()
  return
  if ($y/following-sibling::*:award-group[descendant::*:institution/data() = $i]//*:award-id/data() != $a-id)

 then $article-id
 else ()
)