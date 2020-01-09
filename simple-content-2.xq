declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

for $x in collection('articles')//*:article[descendant::*:body and not(descendant::*:media[@mimetype="video"]) and not(descendant::mml:math) and not(descendant::table-wrap) and not(descendant::fig-group)]
let $c := count($x//*:article-meta/*:contrib-group[not(@*)]/*:contrib)
let $a := count($x//*:article-meta/*:contrib-group[not(@*)]/*:aff)
return
if ($c ge 8) then ()
else if ($a ge 3) then ()
else if ($x//*:fig[descendant::*:supplementary-material]) then ()
else if ($x//*:element-citation[not(@publication-type="journal")]) then ()
else if ($x/@article-type != ('research-article')) then ()
else concat('https://elifesciences.org/articles/',$x/base-uri())
