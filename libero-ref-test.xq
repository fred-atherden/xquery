declare function local:name($name){
  if ($name/*:surname and $name/*:given-names) then ($name/*:surname[1]||' '||$name/*:given-names[1])
  else if ($name/*:surname) then ($name/*:surname[1]/data())
  else if ($name/*:given-names) then ($name/*:given-names[1]/data())
  else if ($name/name()='collab') then $name/data()
};


declare function local:journal($element-citation){
let $display := (string-join(
  for $y in $element-citation/*
  return 
  if ($y/name()='person-group') then (
    if ($y[@person-group-type="editor"]) then (
      if (count($y/*) gt 1) then (string-join(for $c in $y/(*:name|*:string-name|*:collab) return local:name($c),', ')||' (Eds). ')
      else (string-join(for $c in $y/(*:name|*:string-name|*:collab) return local:name($c),', ')||' (Ed). ')
    )
    else (string-join(for $c in $y/(*:name|*:string-name|*:collab) return local:name($c),', ')||'. ')
    )
  else if ($y/name()='date-in-citation' and $y/*) then ('[accessed '||string-join(for $z in $y/* return $z,' ')||']')
  else if ($y/name()='date-in-citation') then ('[accessed '||$y||']')
  else if ($y/*) then string-join(for $z in $y/* return $z,', ')
  else if ($y/name()='volume' and $element-citation/*:issue) then ($y)
  else if ($y/name()='volume' and not($element-citation/*:issue)) then ($y||':')
  else if ($y/name()='issue') then ('('||$y||'):')
  else if ($y/name()='year') then ('('||$y||') ')
  else if ($y/name()='fpage' and $element-citation/*:lpage) then ($y||'-')
  else if ($y/*:lpage and $element-citation/*:fpage) then ($y)
  else if ($y/*:publisher-loc) then ($y||': ')
  else if ($y/@pub-id-type="doi") then ('https//:www.doi.org/'||$y)
  else ($y||'. ')
)||'.')

return replace($display,'\.{1,3}$|\. \.$','.')
};

declare function local:book($element-citation){
let $display := (string-join(
  for $y in $element-citation/*
  return 
  if ($y/name()='person-group') then (
    if ($y[@person-group-type="editor"]) then (
      if (count($y/*) gt 1) then (string-join(for $c in $y/(*:name|*:string-name|*:collab) return local:name($c),', ')||' (Eds). ')
      else (string-join(for $c in $y/(*:name|*:string-name|*:collab) return local:name($c),', ')||' (Ed). ')
    )
    else (string-join(for $c in $y/(*:name|*:string-name|*:collab) return local:name($c),', ')||'. ')
    )
  else if ($y/name()='date-in-citation' and $y/*) then ('[accessed '||string-join(for $z in $y/* return $z,' ')||']')
  else if ($y/name()='date-in-citation') then ('[accessed '||$y||']')
  else if ($y/*) then string-join(for $z in $y/* return $z,', ')
  else if ($y/name()='volume') then ($y||' ')
  else if ($y/name()='year') then ('('||$y||') ')
  else if ($y/name()='fpage' and $element-citation/*:lpage) then ($y||'-')
  else if ($y/*:lpage and $element-citation/*:fpage) then ($y)
  else if ($y/*:publisher-loc) then ($y||': ')
  else if ($y/@pub-id-type="doi") then ('https//:www.doi.org/'||$y)
  else ($y||'. ')
)||'.')

return replace($display,'\.{1,3}$|\. \.$','.')
};

for $y in collection('ijm')//*:article
return (
  ($y/base-uri()||' ------------------------------------- '),
  for $x in $y//*:element-citation
    let $display := if ($x/@publication-type="book") then replace(local:book($x),'\.\.','.')
                else (replace(local:journal($x),'\.\.','.'))
  return normalize-space($display)
)

