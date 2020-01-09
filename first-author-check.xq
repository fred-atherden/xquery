distinct-values(for $x in collection('articles')//*:article
let $c := $x//*:article-meta/*:contrib-group[not(@*)][1]/*:contrib[1] 
return 
if (matches($c,'Seidel')) then $x//article-id[@pub-id-type="publisher-id"]/text()
else ())