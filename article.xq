for $x in collection('articles')//*:article[(descendant::*:article-id[@pub-id-type="publisher-id"]= '42955') and descendant::*:body]
return $x