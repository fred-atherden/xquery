distinct-values(for $x in collection('articles')//*:article[descendant::*:element-citation[@publication-type="book"]]
return $x//*:article-id[@pub-id-type="publisher-id"]/text())