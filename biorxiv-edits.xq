declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";


declare variable $dir := '/Users/fredatherden/Desktop/biorxiv-tranformed/';



for $x in collection('biorxiv-xml')//*:article[not(descendant::*:media[@mimetype="video"]) and not(descendant::mml:math) and not(descendant::table) and not(descendant::fig-group) and not(descendant::disp-quote) and (count(descendant::*:mixed-citation[@publication-type!='journal']) le 3)]
let $filename := concat(substring-after($x//*:article-meta/*:article-id[@pub-id-type="doi"],'10.1101/'),'.xml')
let $file2 := 
copy $copy := $x
modify(
    
    for $x in $copy//*:fig
    let $label := if (ends-with($x/*:label,'.')) then concat($x/*:label/text(),' ')
                  else if (ends-with($x/*:label,'.')) then concat($x/*:label/text(),' ')
                  else concat($x/*:label,'. ')
    return 
    replace node $x with 
    <fig id="{$x/@id}">
    <caption>
    <title>{$label,
            $x/*:caption/*:p/(*|text())}</title>
    </caption>
    <graphic xlink:href="{$x/*:graphic/@xlink:href/string()}" mimetype="image" mime-subtype="tiff" />
    </fig>,
    
    for $x in $copy//*:table-wrap
    let $label := if (ends-with($x/*:label,'.')) then $x/*:label/text()
                  else concat($x/*:label,'. ')
    return 
    replace node $x with 
    <table-wrap id="{$x/@id}">
    <caption>
    <title>{$label,
            $x/*:caption/*:p/(*|text())}</title>
    </caption>
    <graphic xlink:href="{$x/*:graphic/@xlink:href/string()}" mimetype="image" mime-subtype="tiff" />
    </table-wrap>,
  
    for $x in $copy//*:sec[(@sec-type="supplementary-material") and not(child::*[local-name()!='title' and local-name()!='supplementary-material'])]  
    return 
    delete node $x,
    
    for $x in $copy//*:article-meta//*:contrib//*:xref[@ref-type="aff"]
    let $a := $x/ancestor::*:article-meta//*:aff[@id = $x/@rid]
    let $aff := <aff id="{generate-id($x/@rid)}">{
      for $y in $a/(*|text())
      return 
      if ($y/local-name()='label') then ()
      else $y/data() 
    }</aff>
    return 
    replace node $x with $aff,
    
    for $x in $copy//*:article-meta//*:aff
    return delete node $x,
    
    for $x in $copy//*:back/*:ack
    return 
     if ($x/*:title) then (delete node $x,
     insert node <sec>{$x/*}</sec> as last into $x/preceding::body[1])
     else (delete node $x,
     insert node <sec><title>Acknowledgements</title>{$x/*}</sec> as last into $x/preceding::body[1]),
     
    for $x in $copy//*:abstract
    return 
    (delete node $x,
     insert node <sec>{$x/*}</sec> as first into $x/following::body[1])
  
)
return $copy

return file:write(concat($dir,$filename),$file2, map {'indent':'no'})

