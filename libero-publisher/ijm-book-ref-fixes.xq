let $values := ('person-group', 'year', 'chapter-title', 'source', 'volume', 'edition', 'publisher-loc', 'publisher-name', 'fpage', 'lpage', 'page-range', 'elocation-id', 'pub-id', 'ext-link', 'uri', 'comment', 'x', 'isbn')

for $x in collection('ijm')//*:element-citation[@publication-type="book"]
let $id := $x/parent::*:ref/@id
let $y := string-join(distinct-values(for $z in $x/* return if ($z/name()=$values) then () else $z/name()),', ')
return if ($y='') then ()
else ($y||' - '||$id||' - '||$x/base-uri())