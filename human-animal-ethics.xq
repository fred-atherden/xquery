distinct-values(for $x in collection('articles')//*:article[descendant::*:fn-group[@content-type="ethics-information"]]
let $fn := $x//*:fn-group[@content-type="ethics-information"]
let $d := $fn/data()
return if (contains($d,'Human subjects:') and contains($d,'Animal experimentation:') )
  then $x//article-id[@pub-id-type="publisher-id"]/text()
  else ())