declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

declare variable $filename := 'elife-25480.xml';
declare variable $dir := '/Users/fredatherden/Desktop/';
declare variable $file := doc(concat('/Users/fredatherden/Desktop/elife-25480-vor-r1/',$filename));


for $x in $file//*:article
let $y := 

copy $copy := $x
modify(

  for $x in $copy//*:ack
  return (insert node <sec>{$x/*}</sec> as last into $x/preceding::body,
         delete node $x),
         
  for $x in $copy//*:label
  return 
  if ($x/parent::*:aff) then ()
  else if ($x/parent::*:fig) then
    insert node concat($x/text(),' ') as first into $x/following-sibling::caption[1]/*:title
  else if ($x/parent::*:sec) then
    insert node concat($x/text(),' ') as first into $x/following-sibling::*:title[1]
  else if ($x/parent::*:fn) then
    insert node concat($x/text(),' ') as first into $x/following-sibling::p[1]
  else ()
  
)
return $copy


return file:write(concat($dir,$filename),$y, map {'indent':'no'})