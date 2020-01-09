for $x in collection('articles')//*:article[descendant::*:p//named-content[@content-type="sequence"]]
return $x//article-id[@pub-id-type="publisher-id"]