declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

for $x in collection('articles')//*:article[@article-type="research-article" and descendant::*:body and not(descendant::*:media[@mimetype="video"]) and not(descendant::mml:math) and not(descendant::table-wrap)]
let $c := count($x//*:article-meta/*:contrib-group[not(@*)]/*:contrib)
let $a := count($x//*:article-meta/*:contrib-group[not(@*)]/*:aff)
return
if ($c ge 8) then ()
else if ($a ge 3) then ()
else concat('https://elifesciences.org/articles/',$x//*:article-id[@pub-id-type="publisher-id"]/text())
