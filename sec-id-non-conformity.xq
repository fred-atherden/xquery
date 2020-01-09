distinct-values(for $x in collection('articles')//*:article/(*:body|*:back)/*:sec[@id]
let $c := $x/ancestor::*:article//*:article-id[@pub-id-type="publisher-id"]
let $pos := if ($x/parent::*/local-name() = 'body') then count($x/parent::*/*:sec) - count($x/following-sibling::*:sec)
else count($x/ancestor::*:article/*:body/*:sec) + count($x/parent::*:back/*:sec) - count($x/following-sibling::*:sec)
return
if ($x[@sec-type="data-availability"]) then ()
else if (contains($x/@id,'-')) then ($c)
else if ($x/@id = ('s'||$pos)) then ()
else ($c))