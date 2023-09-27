declare function local:median($values as xs:integer*) as xs:float{
  let $count := count($values)
  let $median-number :=  if (($count mod 2)=1) then (($count div 2)+0.5)
                         else (
                            ($count div 2),
                            (($count div 2)+1)
                         )

  let $median := if (count($median-number)=1) then (
                              for $x in $values[position()=$median-number]
                              return $x
                                              )
                 else (sum(for $x in $values[position()=$median-number]
                           return $x) div 2)

  return $median
};

declare variable $folder := "/Users/fredatherden/Desktop/orcid-data/";

let $orcid-data := <xml>{
  for $file in file:list($folder)[ends-with(.,'.xml')]
  let $xml := doc($folder||$file)
  return $xml//*:items/*
}</xml>

for $year in distinct-values($orcid-data//*:date-parts/*:_[@type="array"]/*[1])
order by $year
let $items := $orcid-data/*[*:published-online/*:date-parts/*:_[@type="array"]/*[1]=$year]
let $values := for $x in $items let $count := count($x/*:author/*[*:ORCID]) order by $count return $count
let $median := local:median($values)
return $year||'	'||count($items)||'	'||$median