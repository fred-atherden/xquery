declare function local:get-doi($a){
  if ($a/ancestor::*:article/descendant::*:article-id[@pub-id-type="doi"][1])
  then (
    let $doi := $a/ancestor::*:article/descendant::*:article-id[@pub-id-type="doi"][1]
    let $url := concat('http://doi.org/',$doi)
    return copy $copy := $a
    modify(
      for $x in $copy/descendant-or-self::*:award-group
      return insert node attribute {'url'}{$url} as last into $x
    )
    return $copy)
  
  else $a
};




<list xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">{
for $x in collection('pmc1')//*:article//*:funding-group//*:award-group[*:award-id]
let $id := $x/*:award-id[1]
let $y := replace($id,'[\p{P}\p{N}]|[Gg]rant','')
let $new-x := local:get-doi($x)
return
if (matches($id,'[Nn]o\. ')) then ()
else if (matches($id,'\p{Ll}')) then (
  if (string-length($y) < 10) then ()
  else $new-x)
else ()
}</list>


