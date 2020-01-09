declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

declare variable $dir := '/Users/fredatherden/Desktop/edits-done/';

for $x in collection('edits')//*:article
let $filename := substring-after($x/base-uri(),'/edits/')
let $y := 

copy $copy := $x
modify(
  
  for $y in $copy//*:article-meta//*:abstract
  return (insert node <sec><title>Abstract</title>{$y/*}</sec> as first into $y/following::body[1],
         delete node $y)
  
)
return $copy

return file:write(concat($dir,$filename),$y, map {'indent':'no'})