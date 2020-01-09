distinct-values(for $x in collection('articles')//*:article[(descendant::*:subject[text() = 'Replication Study']) and descendant::*:body]
return $x//*:article-id[@pub-id-type="publisher-id"]/text())