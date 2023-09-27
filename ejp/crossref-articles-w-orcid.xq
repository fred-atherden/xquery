declare variable $folder := "/Users/fredatherden/Desktop/orcid-data/";

let $orcid-data := <xml>{
  for $file in file:list($folder)[ends-with(.,'.xml')]
  let $xml := doc($folder||$file)
  return $xml//*:items/*
}</xml>

for $year in distinct-values($orcid-data//*:date-parts/*:_[@type="array"]/*[1])
order by $year
let $items := $orcid-data/*[*:published-online/*:date-parts/*:_[@type="array"]/*[1]=$year]
let $o-articles := $items[*:author/*[*:ORCID]]
return $year||'	'||count($o-articles)||'	'||count($items)