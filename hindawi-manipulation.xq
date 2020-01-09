declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

declare variable $filename := '8093192.xml';
declare variable $dir := '/Users/fredatherden/Desktop/';
declare variable $file := doc(concat('/Users/fredatherden/Desktop/CRID_8093192_Final_1 copy/',$filename));


for $x in $file//*:article
let $y := 

copy $copy := $x
modify(
    
    for $x in $copy//*:fig
    let $label := if (ends-with($x/*:label,'.')) then $x/*:label/text()
                  else concat($x/*:label,'. ')
    return 
    replace node $x with 
    <fig id="{$x/@id}">
    <caption>
    <title>{$label,
            $x/*:caption/*:p/(*|text())}</title>
    </caption>
    <graphic xlink:href="{concat('floats/',$x/*:graphic/@xlink:href/string(),'.jpg')}" mimetype="image" mime-subtype="jpeg" />
    </fig> 
  
  
)
return $copy


return file:write(concat($dir,$filename),$y, map {'indent':'no'})