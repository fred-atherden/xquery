declare function local:get-doi($a){
  let $id := $a/ancestor::*:article/descendant::*:article-id[@pub-id-type="publisher-id"][1]
  let $version := substring-before(substring-after($a/base-uri(),concat($id,'-')),'.xml')
  let $url := concat('https://elifesciences.org/articles/',$id,$version)
  return copy $copy := $a
  modify(
    for $x in $copy/descendant-or-self::*:award-group
    return insert node attribute {'url'}{$url} as last into $x
  )
  return $copy
};




<list xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">{
for $x in collection('articles')//*:article//*:funding-group//*:award-group[*:award-id]
let $id := $x/*:award-id
let $y := replace($id,'[\p{P}\p{N}]|[Gg]rant','')
let $new-x := local:get-doi($x)
return
if (matches($id,'\p{Ll}')) then (
  if (string-length($y) < 10) then ()
  else $new-x)
else ()
}</list>


