declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

declare variable $filename := 'elife-46962.xml';
declare variable $dir := '/Users/fredatherden/Desktop/';
declare variable $file := doc(concat('/Users/fredatherden/Desktop/elife-46962-vor-r1/',$filename));


for $x in $file//*:article
let $y := 

copy $copy := $x
modify(

  for $x in $copy//*:contrib//*:xref[@ref-type="aff"]
  let $aff := $x/ancestor::*:article-meta//*:aff[@id = $x/@rid]
  return (replace node $x with <aff id="{generate-id($x/@rid)}">{$aff/data()}</aff>),
  
  for $x in $copy//*:aff[not(parent::*:contrib)]
  return delete node $x
  
)
return $copy


return file:write(concat($dir,$filename),$y, map {'indent':'no'})