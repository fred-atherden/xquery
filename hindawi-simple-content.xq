declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

for $x in collection('hindawi-xml')//*:article[not(descendant::table-wrap) and (count(descendant::*:fig-group) le 2)]
let $c := count($x//*:article-meta/*:contrib-group[not(@*)]/*:contrib)
let $a := count($x//*:article-meta/*:contrib-group[not(@*)]/*:aff)
return
if ($c ge 8) then ()
else if ($a ge 3) then ()
else if ($x//*:fig[descendant::*:supplementary-material]) then ()
else $x//*:article-id[@pub-id-type="publisher-id"]/text()
