distinct-values(for $x in collection('articles')//*:article[descendant::*:body]
let $c := count($x//*:contrib-group[not(@content-type="section")]/*:contrib)
return
if ($c = 1) then () 
else if ($x//*:contrib[not(@corresp="yes")and not(descendant::*:xref[@ref-type="corresp"])]//*:email) then $x//article-id[@pub-id-type="publisher-id"]/text()
else ())